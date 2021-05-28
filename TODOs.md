# TODOs

* [ ] Review of the test-bench to see how it behaves without the proprietary samples
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
* [ ] Write a sensible Readme
* [ ] Write (some?) instructions in Workbook
* [ ] Thorough inspection of the workbook & repo to guard against leaks of private information
    * The two "hidden names" are for the queries loaded to a worksheet
    * The "custom XML datas" are the Power Query queries, lolsob.
        * This even includes query groups!!
* **IMPORTANT**
    * [ ] Copy & rename the dev workbook
    * [ ] In the showcase workbook, blank RepoRoot
    * [ ] Save after blanking RepoRoot
    * [ ] Close showcase workbook
    * [ ] Open showcase workbook
    * [ ] Verify RepoRoot
    * [ ] Perform final inspection of showcase workbook
        * [ ] Document Inspector
        * [ ] Don't remove:
            * Hidden names (they're for loaded queries)
            * Custom XML (That "custom" XML is actually Power Query, lolsob
        * [ ] Re-enable the recording of document properties on save
        * [ ] Save & Close
        * [ ] Inspect the unzipped XML
    * [ ] Allow showcase workbook to be tracked by Git
* [ ] Make the repo public
* [ ] Take screenshots & tweet a glorious thread