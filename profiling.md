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

## Buffering source binary image

| Stage         | Cumulative | Alone | Diff |
|----------------------|------|------|------|
| Run Length Encoding  |  |  |
| All Top Neighbours   |  |  |
| Right Neighbours     |  |  |
| All Unique Relations |  |  |
| All Adjacencies      | 6:33 | 1:36 | +33s
| Formatted Output     |  |  |
