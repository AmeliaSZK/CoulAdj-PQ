# PNG File Format Synthesis

Informations mostly taken from the [Wikipedia](https://en.wikipedia.org/wiki/Portable_Network_Graphics).
Fortunately, unlike with the Bitmap format, there is an [official standard](https://www.w3.org/TR/PNG/).

Some parts were copy-pasted from the official standard. The following notices
are thus provided to comply with the license:

"Copyright © 2003 W3C® (MIT, ERCIM, Keio). 
This software or document includes material copied from or derived from
[Portable Network Graphics (PNG) Specification (Second Edition)](https://www.w3.org/TR/PNG/)."

[List of authors](https://www.w3.org/TR/PNG/#F-Relationship)

[Errata regarding the RGB ordering](https://www.w3.org/2003/11/REC-PNG-20031110-errata)

# Bytes Layout

## Magic Number
A PNG file always start with these 8 bytes:
```
89 50 4E 47 0D 0A 1A 0A
```
(These values are in hexadecimal)

## Chunks
The magic number is followed by "chunks" composed of these fields that
appear in this order:

| Field Name | Length (big-endian) |
|------------|---------------------|
| Length     | 4 bytes |
| Chunk Type | 4 bytes |
| Chunk Data | _Length_ bytes |
| CRC        | 4 bytes |

Chunks can be _critical_ or _auxiliary_. Critical chunks are essential to
decode the file. Auxiliary chunks can be ignored if they're not recognised.

## Chunk Type
This field is a four-letter case _sensitive_ code.
The case (uppercase vs lowercase) of each letter tells the decoder what
to do with chunks it doesn't recognize.

| Letter | If Uppercase   | If Lowercase    | Notes |
|--------|----------------|-----------------|-------|
| 1st    | Critical chunk | Auxiliary chunk | If critical & unrecognized, must abort or give warning |
| 2nd    | Public chunk   | Private chunk   | "Public" is standardised. "Private" is free for all. The distinction to avoid name collisions between private and public chunks |
| 3rd    | Conform to spec| Unrecognised    | Reserves for future use |
| 4th    | Can copy if not modifications on any critical chunk | Always safe to copy | Both options only apply to unrecognized chunks |

## Critical chunks

### `IHDR` Image Header
`IHDR` must be the first chunk.

| Field | Length | Notes |
|-------|--------|-------|
| Width              | 4 bytes | uint |
| Height             | 4 bytes | uint |
| Bit depth          | 1 byte  | 1, 2, 4, 8, or 16 (1) |
| Colour type        | 1 byte  | 0, 2, 3, 4, or 6 (1) |
| Compression method | 1 byte  | Only 0 is allowed |
| Filter method      | 1 byte  | Only 0 is allowed, but it could mean something |
| Interlace method   | 1 byte  | 0 is no interlace, 1 is for Adam7 interlace |

(1: Only some combinations allowed, see table 11.1)
(The number 11.1 comes from the official standard)

#### Table 11.1 — Allowed combinations of colour type and bit depth
| PNG image type      | Colour type | Allowed bit depths | Interpretation |
|---------------------|-------------|--------------------|----------------|
|Greyscale            | 0           | 1, 2, 4, 8, 16     | Each pixel is a greyscale sample |
|Truecolour           | 2           | 8, 16              | Each pixel is an R,G,B triple |
|Indexed-colour       | 3           | 1, 2, 4, 8         | Each pixel is a palette index; a PLTE chunk shall appear. |
|Greyscale with alpha | 4           | 8, 16              | Each pixel is a greyscale sample followed by an alpha sample. |
|Truecolour with alpha| 6           | 8, 16              | Each pixel is an R,G,B triple followed by an alpha sample. |

