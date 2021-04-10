# PNG File Format Synthesis

Informations mostly taken from the [Wikipedia](https://en.wikipedia.org/wiki/Portable_Network_Graphics).
Fortunately, unlike with the Bitmap format, there is an [official standard](https://www.w3.org/TR/PNG/).

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

### Chunk Type
This field is a four-letter case _sensitive_ code.
The case (uppercase vs lowercase) of each letter tells the decoder what
to do with chunks it doesn't recognize.

| Letter | If Uppercase   | If Lowercase    | Notes |
|--------|----------------|-----------------|-------|
| 1st    | Critical chunk | Auxiliary chunk | If critical & unrecognized, must abort or give warning |
| 2nd    | Public chunk   | Private chunk   | "Public" is standardised. "Private" is free for all. The distinction to avoid name collisions between private and public chunks |
| 3rd    | Conform to spec| Unrecognised    | Reserves for future use |
| 4th    | Can copy if not modifications on any critical chunk | Always safe to copy | Both options only apply to unrecognized chunks |

