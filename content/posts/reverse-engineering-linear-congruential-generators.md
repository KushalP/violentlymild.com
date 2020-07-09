+++
date = "2020-07-09T11:00:00Z"
title = "Reverse engineering linear congruential generators"
aliases = ["reverse-engineering-linear-congruential-generators"]
+++

*Last year I helped a friend as they tried to reverse engineer a piece
of software and this blog post contains some rough notes on what we
did at a specific step*

## Producing random numbers

When doing common cryptographic operations it’s important to be able
to produce a random number. The goal is to produce a number or a set
of numbers, such that there is no way to reliably predict how that
number was generated. However it can be expensive to produce a random
number, so many developers over the years have opted to use a
[pseudorandom number
generator](https://en.wikipedia.org/wiki/Pseudorandom_number_generator)
(PRNG) instead.

An example of this is Java's java.util.Random:

```java
Random random = new Random();
System.out.format("random integer = %d\n", random.nextInt());
```

One of the most widely used PRNGs is a [linear congruential
generator](https://en.wikipedia.org/wiki/Linear_congruential_generator). Due
to their *linear* nature however if you observe enough of numbers
generated you can work out how the numbers are produced.

## Linear congruential generator

A linear congruential generator (LCG) is an algorithm that produces a
sequence of pseudorandom numbers. It’s one of the oldest algorithms,
easy to implement, and fast. It could be used when generating some
initial values in the process of creating a salt, nonce, or key.

The algorithm for the LCG can be described as follows:

```
s(n+1) = a * s(n) + b mod m

// s(n) is the state
// a is the multiplier
// b is the increment
// m is the modulus
```

Here’s an implementation in Rust:

```rust
#[derive(Clone, Copy, Debug)]
struct LinearCongruentialGenerator {
    state: i128,
    multiplier: i128,
    increment: i128,
    modulus: i128
}

impl Iterator for LinearCongruentialGenerator {
    type Item = i128;

    fn next(&mut self) -> Option<i128> {
        let next_state = (self.state * self.multiplier + self.increment) % self.modulus;
        self.state = next_state;
        Some(next_state)
    }
}

fn main() {
    let lgc = LinearCongruentialGenerator {
        state: 1, // Our seed value when we begin.
        multiplier: 6329,
        increment: 43291,
        modulus: 4294967301, // Picking this value because it's a prime number: 2**32 + 5
    };

    let states: Vec<i128> = lgc.take(10).collect();
    println!("states: {:?}", states);
}
```

If you were to compile and run this it would produce the following output:

```
states: [49620, 314088271, 3589817388, 3872236954, 304305651, 1805157622, 229612269, 1517146054, 2765501322, 866158654]
```

Given that the seeded state value, multiplier, increment, and modulus
value are all stated here, we can create another LCG and it will
always produce the above output.

## Reverse engineering the algorithm

It rarely occurs in cryptography research, but having the linear
output of a pseudorandom number generator means we can use this
information to work out what the initial values are. We can reverse
engineer it!

### The maths

In our Rust example above you can see that the state is updated by
applying two constant (multiplier and increment) and a modulus to the
existing state. The new state is a successive value of the existing
state. If you have three successive outputs (s0, s1, and s2) then you
get two linear equations in two unknowns (multiplier and increment),
which can be solved with simple arithmetic.

### An unknown increment

Let’s assume that we don’t know one parameter of our LCG: the
increment.

We can work out the increment parameter for an LCG using a simple
linear equation approach. When we have the modulus and the multiplier
we can model them next to each other:

```
49620     = (1 * multiplier + increment) % modulus

// Can be rewritten as:
increment = (49620 - 1 * multiplier) % modulus
increment = (49620 - 1 *       6329) % 4294967301
```

```rust
fn find_unknown_increment(states: &[i128], multiplier: i128, modulus: i128) -> (i128, i128, i128) {
    let increment = (states[1] - states[0] * multiplier) % modulus;
    (multiplier, increment, modulus)
}
```

Passing in the output state above, the multiplier, and modulus we will
receive the following tuple:

```rust
find_unknown_increment(&states, lgc.multiplier, lgc.modulus)
=> (6329, 43291, 4294967301)
```

## An unknown increment and multiplier

Let’s make things a little difficult now and assume that we don’t know
the increment or the multiplier, and only know the modulus. We know
that our LCG generates numbers using the following linear equation:

```
s0 = (seed * multiplier + increment) % modulus
s1 = (s0   * multiplier + increment) % modulus
s2 = (s1   * multiplier + increment) % modulus
```

If we have any three linear values produced by our LCG we can rewrite
these linear equations into another form to get our multiplier:

```
s2 - s1 = s1 * multiplier - s0 * multiplier % modulus
s2 - s1 = multiplier * (s1 - s0) % modulus
multiplier = (s2 - s1) / (s1 - s0) % modulus
```

```rust
/// Implementation of the extended Euclidean algorithm
fn egcd(a: i128, b: i128) -> (i128, i128, i128) {
    if a == 0 {
        (b, 0, 1)
    } else {
        let (g, y, x) = egcd(b % a, a);
        (g, x - (b / a) * y, y)
    }
}

fn mod_inverse(a: i128, m: i128) -> Result<i128, &'static str> {
    let (g, x, _) = egcd(a, m);

    return if g != 1 {
        Err("mod inverse does not exist for 1")
    } else {
        Ok(x % m)
    }
}

fn find_unknown_multiplier(states: &[i128], modulus: i128) -> (i128, i128, i128) {
    let multiplier = (states[2] - states[1]) * mod_inverse(states[1] - states[0], modulus).unwrap() % modulus;
    find_unknown_increment(states, multiplier, modulus)
}
```

Passing in our states and modulus, we receive the following tuple as
expected:

```rust
find_unknown_multiplier(&states, lgc.modulus)
=> (6329, 43291, 4294967301)
```

## All parameters are unknown

Let’s really make it more realistic now and assume that all parameters
are unknown. This is exactly the scenario that we were dealing with.

We don’t know the modulus value so every equation we form will have
another unknown that we’ll have to deal with.

### Greatest common divisor

In mathematics, if you have a set of random multiples of N there is a
large probability that their greatest common divisor will be equal to
N. Here is some code as an example:

```rust
fn gcd(a: i128, b: i128) -> i128 {
    if b == 0 {
        a.abs()
    } else {
        gcd(b, a % b)
    }
}

let n: i128 = 17;
let mut rng = rand::thread_rng();
let random_numbers: Vec<i128> = vec![1, 2, 3].iter().map(|_| rng.gen::<u32>() as i128 * n).collect();
random_numbers.iter().fold(0, |a, b| gcd(a, *b))
=> 17
```

This is useful because we can look at some modulus operations that
correspond to zero then we can use that as a basis to build our linear
equations from.

```
x = 0 mod n
x = k * n
```

The above is only useful to us if x is not equal to zero, which we
expect to be the case as we’re working with PRNGs. Given this, we can
take the greatest common divisor from these values and recover n.

Here is how this would be modelled:

```
// Calculate the difference of the states
t0 = s1 - s0
t1 = s2 - s1 = (s1 * m + c) - (s0 * m + c) = m * (s1 - s0) = m * t0 (mod n)
t2 = s3 - s2 = (s2 * m + c) - (s1 * m + c) = m * (s2 - s1) = m * t1 (mod n)

// Build a matrix of the differences
u0 = t2 * t0 - t1 * t1 = (m * m * t0 * t0) - (m * t0 * m * t0) = 0 (mod n)

// Find the greatest common divisor of the differences
m = gcd(u0, u1, u2, ...)

```

Using this method we can now find the modulus of our LCG and find out
the multiplier and the increment.

```rust
fn find_unknown_params(states: &[i128]) -> (i128, i128, i128) {
    let offset_states = &states[1..];
    // Zip together the state lists, adjusted by one position.
    let zipped_states = states.iter().zip(offset_states.iter());
    // Calculate the difference of the states.
    let diffs: Vec<i128> = zipped_states.map(|(k0, k1)| k1 - k0).collect();
    // Build the matrix of the differences
    let zipped_diffs = diffs.iter().zip(diffs.iter().skip(1)).zip(diffs.iter().skip(2));
    let zeroes = zipped_diffs.map(|((s0, s1), s2)| s2 * s0 - s1 * s1);
    // Find the greatest common divisor of the differences
    let modulus = zeroes.fold(0, |a, b| gcd(a, b));
    find_unknown_multiplier(states, modulus)
}

find_unknown_params(&states)
=> (6329, 43291, 4294967301)
```

### What we've done

With this method we have just reverse engineered an LCG, without brute
forcing and with close to zero knowledge. We have done this by
observing its output.

Unfortunately we can’t reverse engineer every LCG now. We were only
able to do what we did because the operations are linear and we get a
complete state of the LCG every time. This is almost too perfect a
situation.

It is much more common to find the above attack disrupted with a few
simple techniques like truncating the produced value each time
(generate an i64 and truncate to an i32), or doing some additional
modulo operation on the way. This is all done to improve the number
distribution of the PRNG.

### Using the default values

If you do come across a linear sequence in the real world, there are
simpler steps you can take than trying to sequence them using the
approach outlined above.

Developers are lazy. It is quite likely that they are using the
default configuration for their LCG on their platform of choice which
can be found on
[Wikipedia](https://en.wikipedia.org/wiki/Linear_congruential_generator#Parameters_in_common_use).

You can plug these configuration values in and see if they produce a
similar pattern by iterating through the seeds. For example, here is
how we could reproduce the LCG configuration commonly used in
java.util.Random, POSIX rand48, and glibc rand48:

```rust
let lgc = LinearCongruentialGenerator {
    state: // Left as a search exercise for the reader.
    multiplier: 25214903917,
    increment: 11,
    modulus: 2.pow(48)
};
```

## References

A lot of what I’ve covered in this blog has been learnt from George
Marsaglia’s paper [Random numbers fall mainly in the
planes](https://www.pnas.org/content/61/1/25). In that paper he
explains how he found the flaw that LCGs are mainly "falling into the
planes". This is where any three consecutive integers with a common
multiplier fall on the lattice of points generated by all linear
combinations of the three points:

```
(1, a, a*a)
(0, m, 0)
(0, 0, m)
```

He goes on to state that any point falls on the lattice generated by (1, a), (0, m).
