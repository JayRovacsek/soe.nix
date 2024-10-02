# soe.nix

A Nixos / Darwin wrapper for system configurations that applies a standard operating environment (SOE) approach
to system management. Note that for the remainder of the readme the concept of a SOE will be
referenced as a "profile" (except in code examples)

# Purpose

This flake intends to make configuration of systems more approachable by breaking the problem down into
profiles that can be layered to segments. Consider it to be a parallel to the docker layer concept,
but intentionally chaining inputs and therefore making the end result both far more reproducible and
configurable by a consumer.

# Background

This flake assumes a basic understanding of the nix language as well as nixos/nix-darwin.
Consider reading these resources if you haven't already:

- [how nix works](https://nixos.org/guides/how-nix-works.html) - a 10,000 foot view of how nix works
- [nix language basics](https://nixos.org/guides/nix-language.html#reading-nix-language) - basics of the nix language
- [nix-pills](https://nixos.org/guides/nix-pills/) - a high-level coverage of most things nix
- [nix.dev](https://nix.dev/) - further coverage of the how/why/when/what of nix in general across a number of domains
-

## Theory of Operation

Normally, a nixosConfiguration might simply break down code blocks by atomic function
such as programs, services, hardware or more. This is fine when a contributor
is intended to have absolute control over their own system, but in an instance where
stronger confidence is required around the configuration of a compute device it
may be desirable to enforce some settings that a user cannot modify, while still
giving the user ability to change other elements of their computing experience.

By breaking down layers of a configuration into code that cannot be modified by
upstream user opinions we achieve a more traditional SOE approach while still enabling
a user's choices in configuration at varying levels.
