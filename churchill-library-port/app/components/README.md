# The Churchill Library Component Library

This component library is my attempt at implementing atomic design for the app where:
- [Atoms](./atoms) provide the basic building blocks e.g., Text, Headings, Buttons, Inputs.
- [Molecules](./molecules) provide the next level of building blocks which utilize atoms to create a single-purpose unit with distinct functionality e.g., Search Form.
- [Organisms](./organisms) provide complex components composed of both atoms & molecules e.g., Header, Footer, Table.

Given Next.js utilizes file-system based routing,
the layout and pages are laid out in accordance to the framework rather than within this directory structure.

I utilized the
[web version for Atomic Design](https://atomicdesign.bradfrost.com/)
to learn more about the ideas of atomic design.
