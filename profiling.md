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
First two compared to _All Adjacencies with Table.ToColumns without buffering_

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
| Formatted Output     | 2:28 | ? | -4:37

## Cleaned-up RLE & full profile
Compared with _After first clean up_

| Stage         | Cumulative | Alone | Diff |
|----------------------|------|------|------|
| Run Length Encoding  | 0:11 | 0:11 | -56s
| All Top Neighbours   | 0:38 | 0:27 | -2:24
| Right Neighbours     | 0:22 | 0:11 | -46s
| All Unique Relations | 1:00 | 0:22 | -37s
| All Adjacencies      | 1:36 | 0:36 | -1:10
| Formatted Output     | 2:34 | 0:58 | +1:36

# Others

## Removed sorting of the output
Compared with _Cleaned-up RLE & full profile_

| Stage         | Cumulative | Alone | Diff |
|----------------------|------|------|------|
| Run Length Encoding  |  |  | 
| All Top Neighbours   |  |  | 
| Right Neighbours     |  |  | 
| All Unique Relations |  |  | 
| All Adjacencies      |  |  | 
| Formatted Output     | 2:01 | 0:25 | -33s

## Consolidated Top Center Neighbours filtering


| Stage         | Cumulative | Alone | Diff |
|----------------------|------|------|------|
| Run Length Encoding  |  |  | 
| All Top Neighbours   |  |  | 
| Right Neighbours     |  |  | 
| All Unique Relations |  |  | 
| All Adjacencies      |  |  | 
| Formatted Output     | 2:02 |  | 

# Final profile before merging into the main branch
This profiling concludes this initial wave of optimizations.
While more optimizations may come, the next phase will be to make
the bitmap parser more robust, and also to clean-up and consolidate the code.

By "consolidate", I mean to merge all the queries into one, because the final
form of this implementation of CoulAdj will be a single Power Query function.

## Future optimizations

There are two more major optimizations attempts that I anticipate:
* Merge-sort
* List of don't cares

### Merge-sort
The merge-sort would replace how we get the list of segments on the next
scanline adjacent to the current segment.
Currently, after doing the run length encoding, all segments are joined
with all segments on the next scanline, like this:

Before:
| Scanline | Colour | Start | End |
| ---------|---------|-------|-----|
| 1 | A | 0 | 2 |
| 1 | B | 2 | 7 |
| 1 | C | 7 | 9 |
| 2 | D | 0 | 4 |
| 2 | E | 4 | 6 |
| 2 | F | 6 | 9 |

After (only scanline 1 is shown):
| Scanline | Colour | Start | End | Next Scanline | Next Colour | Next Start | Next End |
| ---------|--------|-------|-----|--------------:|------------:|-----------:|---------:|
| 1 | A | 0 | 2 | 2 | D | 0 | 4 |
| 1 | A | 0 | 2 | 2 | E | 4 | 6 |
| 1 | A | 0 | 2 | 2 | F | 6 | 9 |
| 1 | B | 2 | 7 | 2 | D | 0 | 4 |
| 1 | B | 2 | 7 | 2 | E | 4 | 6 |
| 1 | B | 2 | 7 | 2 | F | 6 | 9 |
| 1 | C | 7 | 9 | 2 | D | 0 | 4 |
| 1 | C | 7 | 9 | 2 | E | 4 | 6 |
| 1 | C | 7 | 9 | 2 | F | 6 | 9 |

We then filter for the adjacent segments by keeping rows where
```
[Start] <= [Next End] and [Next Start] <= [End]
```

And in our example, this would yield:
| Scanline | Colour | Start | End | Next Scanline | Next Colour | Next Start | Next End |
| ---------|--------|-------|-----|--------------:|------------:|-----------:|---------:|
| 1 | A | 0 | 2 | 2 | D | 0 | 4 |
| 1 | B | 2 | 7 | 2 | D | 0 | 4 |
| 1 | B | 2 | 7 | 2 | E | 4 | 6 |
| 1 | B | 2 | 7 | 2 | F | 6 | 9 |
| 1 | C | 7 | 9 | 2 | F | 6 | 9 |

Illustration of the example scanlines:
```
A A B B B B B C C
D D D D E E F F F
```

This method is wasteful, because once we know that a segment on scanline #2
ended before the start of the current segment on scanline #1, well all other
segments that will follow on scanline #1 will also start after.

We believe that a form of merge-sort could help avoid the unnecessary 
comparisons. We made an attempt with `Table.Join` and `JoinAlgorithm.SortMerge`,
but the `keyEqualityComparers` we thought we could exploit isn't allowed to be
used by the engine.

So we would need to implement our own sort-merge, and that seems like a lot of
work prone to bugs leading to potentially incorrect results.

### List of don't cares
This list would be use to filter the result of the run length encoding to
remove all colours that we don't care about. This would mean that we have
to compare less segments.

This list would be coming from the sea regions in a given Total War map.

(This section is short because I don't want to be spending so much more
time on documentation right now...)

## Profiling

| Stage         | Cumulative | Alone |
|----------------------|------|------|
| Run Length Encoding  | 0:10 | 0:10 |
| All Top Neighbours   | 0:36 | 0:26 |
| Right Neighbours     | 0:21 | 0:11 |
| All Unique Relations | 0:57 | 0:21 |
| All Adjacencies      | 1:28 | 0:31 |
| Formatted Output     | 1:34 | 0:06 |


# Merge-sort
These attempts were started several weeks after the previous.

## Baseline
1:35 with Mortal Empires, before the merge-sort.
All measurements are done with Mortal Empires in the Merge-sort section.

## First correct implementation
1:19

Not complete, because we don't use merge-sort for the segments on the same scanline.
Also, the way diagonals are handled is not ideal, and may be suffering in 
performance because it isn't properly buffered.

## 2nd implementation
1:43

## Table.Distinct Big O
Durations are in minutes:seconds.fractionalSeconds

| Count   | Generate | Distinct |
| 100     | 0:00.10  | 0:00.10  |
| 1000    | 0:00.13  | 0:00.10  |
| 10,000  | 0:00.11  | 0:00.15  |
| 100,000 | 0:00.34  | 0:00.21  |
| 1,000,000   |      | 0:01.17  |
| 10,000,000  |      | 0:07.55  |
| 100,000,000 |      | 1:15.07  |



