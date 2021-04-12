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
* In RightNeighbours, consider purging both before the min-max and after. 
    * (At the time of writing, we are only purging after)