# CoulAdj-PQ
Computes the list of adjacent colours for each colour in an image. Power Query implementation.


# TODOs

* Get test samples to bitmap (DONE)
    * Or write a Power Query function to parse PNG images, LOL
    * This is such a bad idea lol, do I really want to spend time on this?
    * Such a bad idea, ha ha ha, ha ha ha... (Unless...? 👀)
    * The TSV parser was abandonned because of the filtering step 😑
* Setup correctness test bench in workbook (GOOD ENOUGH)
* Setup performance test bench in workbook

# Potential optimizations

* When generating symmetrical adjacencies, consider using Table.Combine
* In ProcessSubtables for RightNeighbours, consider doing the min-max & purge there
    * Done, we went from 2m01s to 1m59s. (So basically noise)
* In RightNeighbours, consider purging both before the min-max and after. 
    * (At the time of writing, we are only purging after)
* In AllTopNeighbours, consider using 1 statement to keep Top Center neighbours
* Alpha column? When to remove? Always add? How is the sort affected? Is the sort even long???
* When ~~grouping by Row Index~~ calculating RLE, considering using GroupKind.Local?
    * Done, it was the most important optimization. Went from 7m04s to 2m34s.
    * Amazingly, it didn't just make the RLE section faster, but most other sections too!
    * This amazing result was from local groups during RLE, not Row Index tho.
    * Other local groups in Row Index etc didn't give meaningful benefits
* In EncodeRunLenght, consider using List.First to get Start?
    * Done, and also used List.Last+1 to get End. No meaningful improvement,
    but it was measured before doing Local Groups.
* In EncodeRunLenght, consider buffering the binary values?
    * Buffering the input of ParseBitmap didn't help.
    * Buffering the binary cells in the RLE with `Table.TransformColumns` also didn't help.


