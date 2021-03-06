# TODOs

* [x] Review of the test-bench ~~to see how it behaves without the proprietary samples~~
    * [x] Reviewed
    * [x] What happens without proprietary?
        * Nothing if you use a synthetic sample.
        You can select a proprietary for input, but
        then you'll get errors.
* [x] Figure out what to do with the RepoRoot parameter
    * Don't track the dev workbook in the repo
    * Make a copy for the showcase
    * ~~The copy will have that parameter blanked before Gitting(?)~~
        * Let it stand, because my absolute path to the workbook will have
        to be leaked anyway... 😒
    * Aside from this, the showcase workbook should be identical
    to the dev workbook at the time of creation
* [x] Write a sensible Readme
* [x] Write (some?) instructions in Workbook
* [x] Thorough inspection of the workbook & repo to guard against leaks of private information
    * The two "hidden names" are for the queries loaded to a worksheet
    * The "custom XML datas" are the Power Query queries, lolsob.
        * This even includes query groups!!
* **IMPORTANT**
    * [x] Copy & rename the dev workbook
    * [x] Perform final inspection of showcase workbook
        * [x] Document Inspector
        * [x] Don't remove:
            * Hidden names (they're for loaded queries)
            * Custom XML (That "custom" XML is actually Power Query, lolsob
        * [x] Re-enable the recording of document properties on save
        * [x] Save & Close
    * [x] Allow showcase workbook to be tracked by Git
* [ ] Make the repo public
* [ ] Take screenshots & tweet a glorious thread