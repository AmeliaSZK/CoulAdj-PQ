# After 1st clean up

| Stage         | Cumulative | Alone |
|----------------------|------|------|
| Run Length Encoding  | 1:07 | 1:07 |
| All Top Neighbours   | 3:58 | 2:51 |
| Right Neighbours     | 2:04 | 0:57 |
| All Unique Relations | 4:57 | 0:59 |
| All Adjacencies      | 6:43 | 1:46 |
| Formatted Output     | 7:05 | 0:22 |


# All Adjacencies with Table.ToColumns 
Both compared to _After 1st clean up_

## With buffering

| Stage         | Cumulative | Alone | Diff |
|----------------------|------|------|------|
| Run Length Encoding  |  |  |
| All Top Neighbours   |  |  |
| Right Neighbours     |  |  |
| All Unique Relations |  |  |
| All Adjacencies      | 7:13 | 2:16 | +30s
| Formatted Output     |  |  |

## _Without_ buffering

| Stage         | Cumulative | Alone | Diff |
|----------------------|------|------|------|
| Run Length Encoding  |  |  |
| All Top Neighbours   |  |  |
| Right Neighbours     |  |  |
| All Unique Relations |  |  |
| All Adjacencies      | 6:00 | 1:03 | -43s
| Formatted Output     |  |  |

# Binary Buffering
All compared to _All Adjacencies with Table.ToColumns without buffering_

## Buffering only source binary image

| Stage         | Cumulative | Alone | Diff |
|----------------------|------|------|------|
| Run Length Encoding  |  |  |
| All Top Neighbours   |  |  |
| Right Neighbours     |  |  |
| All Unique Relations |  |  |
| All Adjacencies      | 6:33 | 1:36 | +33s
| Formatted Output     |  |  |

## Buffering only binary cell colours

| Stage         | Cumulative | Alone | Diff |
|----------------------|------|------|------|
| Run Length Encoding  | 1:08 | 1:08 | +1s
| All Top Neighbours   |  |  |
| Right Neighbours     |  |  |
| All Unique Relations |  |  |
| All Adjacencies      | 6:23 | 1:26 | +23s
| Formatted Output     |  |  |

## Removed all bufferings

| Stage         | Cumulative | Alone | Diff |
|----------------------|------|------|------|
| Run Length Encoding  | 1:07 | 1:07 | 0
| All Top Neighbours   |  |  |
| Right Neighbours     |  |  |
| All Unique Relations |  |  |
| All Adjacencies      | 7:13 | 2:16 | +1:13s
| Formatted Output     |  |  |

This is equivalent to All Adjacencies with Table.ToColumns *with* buffering,
and my hypothesis is that the 6 minutes result benefited from a cache somewhere.

# RLE
All compared to _All Adjacencies with Table.ToColumns without buffering_

## Used List.First and List.Last+1 for Start and End

| Stage         | Cumulative | Alone | Diff |
|----------------------|------|------|------|
| Run Length Encoding  | 1:03 | 1:03 | -4s
| All Top Neighbours   |  |  |
| Right Neighbours     |  |  |
| All Unique Relations |  |  |
| All Adjacencies      |  |  |
| Formatted Output     |  |  |

## Also used local groups in RLE

| Stage         | Cumulative | Alone | Diff |
|----------------------|------|------|------|
| Run Length Encoding  | 0:13 | 0:13 | -50s
| All Top Neighbours   |  |  |
| Right Neighbours     |  |  |
| All Unique Relations |  |  |
| All Adjacencies      |  |  |
| Formatted Output     |  |  |

