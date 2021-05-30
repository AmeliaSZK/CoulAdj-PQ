This repository was made public so that I could share with my Twitter
friends & followers.

NOTHING IN HERE IS INTENDED FOR PUBLIC CONSUMPTION.
NO GUARANTEE IS GIVEN OR IMPLIED,
I AM NOT RESPONSIBLE FOR ANYTHING,
BLA BLA BLA, YOU KNOW THE DRILL,
USE ARE YOUR OWN RISKS.

If you are nonetheless going to use this in production, these are
the main issues that, in my opinion, you should be mindful of:
1. ⚠️ **Privacy Warning**: To make the workbook functional, it *will* need to save the file path where it is located. 
Anyone with a copy of your workbook will be able to 
**retrieve the absolute file path to your workbook**.
1. The bitmap parser, `GQ_ParseBitmap`, only supports a **subset of the BMP spec**, 
and an unsupported input may **return incorrect results** instead of an error.

You are welcome to clone and fork, but be please be aware that I may put back
this repository to private at any time.

# CoulAdj-PQ
CoulAdj-PQ is a set of two Power Query functions that, together, will compute,
for each colour in a bitmap image, the list of all adjacent colours.

These two functions are `GQ_ParseBitmap` and `GQ_CoulAdj`. 
GQ_ParseBitmap can be used as a standalone, 
but GQ_CoulAdj strongly depends on GQ_ParseBitmap to work.

This repository is where I developped CoulAdj-PQ, and its main purpose is 
now to showcase my work to my Twitter friends & followers. More specifically,
this Readme caters to two main audiences:
* People who want to read the code, but can't or won't use the Excel workbook.
* People who can and want to see the code in action in the workbook.

I did not include exhaustive instructions on how to setup your local copy of the
repository & workbook to continue development, nor how to just use CoulAdj-PQ
in your own project, because writing all this documentation is starting to
become frustatingly exhausting. *(hahaha, get it? exhaustive...exhausting* 😅 *)*

> Long story short, to develop, you'll need to unzip the `bmp-samples.zip`, and
the proprietary samples are in the Assembly Kit for Total War Warhammer 2. 
Search for .bmp files of ~50 MB. Copy them to `./tests/proprietary`. Look in [GQ_ImageUnderTest_Name](./src/GQ_ImageUnderTest_Name.pq) for how to rename them.

> To use, all you need is to copy-paste the content of 
[GQ_ParseBitmap](./src/GQ_ParseBitmap.pq) 
and [GQ_CoulAdj](./src/GQ_CoulAdj.pq). Everything else is for debug and development.

## Known Requirements

### Read the code
If you do not mind not having syntax colouring, your web browser and this Github
repository are enough.

To get syntax colouring, you have two options:
1. [Visual Studio Code](https://code.visualstudio.com/) 
with the extension [Power Query / M Language](https://marketplace.visualstudio.com/items?itemName=PowerQuery.vscode-powerquery), made by Microsoft
1. The [Power Query Formatter](https://www.powerqueryformatter.com/formatter) website

### Use the workbook
* Windows
* Microsoft Excel

The workbook was made on Windows 10 and Excel 365. I don't know if it will
work on other versions. Excel 2016 may break. Excel 2019 will probably work.

As of May 2021, and as far as I know, Excel for Mac will not work, 
nor will Excel Online. I could be wrong about Mac, but don't get your hopes up.
The phone app (apps?) will also not work.

# Instructions
These first instructions apply to both people who only want to read the code,
and those who will use the workbook.

The two queries I recommend you to spend most of your attention on are the
Showcase queries:
* [GQ_ParseBitmap_Showcase](./src/GQ_ParseBitmap_Showcase.pq)
    * Reads a binary bitmap image file, and outputs data structures 
    native to Power Query.
* [GQ_CoulAdj_Showcase](./src/GQ_CoulAdj_Showcase.pq)
    * Computes the colour adjacencies in the image.

These queries are a copy-paste of the "real" queries, with the ~150 lines of
user documentation removed so that you can more easily tell where the
actual code starts. Additionally, the showcase queries were adapted with mock
inputs, so that workbook users could explore intermediary results 
in the Power Query GUI.

The "real" queries are:
* [GQ_ParseBitmap](./src/GQ_ParseBitmap.pq)
* [GQ_CoulAdj](./src/GQ_CoulAdj.pq)

Below are screenshots of GQ_CoulAdj and its showcase equivalent in the GUI.
Notice that:
* `GQ_CoulAdj` (1st image) has user documentation in the main area, 
and only one step in the right side pane
* `GQ_CoulAdj_Showcase` (2nd image) has results in the main area,
and many steps in the right side pane

### The function
![GQ_CoulAdj with user documentation and one step in the side pane](./doc/GUI-CoulAdj.png "The GQ_CoulAdj function")

### The showcase
![GQ_CoulAdj_Showcase with results and many steps](./doc/GUI-CoulAdj-Showcase.png "The GQ_CoulAdj showcase")

Apart of these four queries, we have:

### Parameter queries
* `GQ_ImageUnderTest_Name`
* `GQ_DontRelateDiagonals`

These provide togglable inputs for use in the testbench and showcase queries.

> You may have noticed `RepoRoot` in the screenshots. It isn't prefixed with
`GQ_` so that my macros won't export it in the Git repo. 
The idea was to prevent any of my file paths to be committed to the repo. 
Notice how [line 2 in GQ_TB_ImageBinaries](https://github.com/AmeliaSZK/CoulAdj-PQ/blob/d6276e4b00365d8c876dce1835695a70ec04e734/src/GQ_TB_ImageBinaries.pq#L2) refers
to `RepoRoot` instead of a folder path. Unfortunately, it kind of became
pointless when I decided to allow that path to leak because I wanted to include
a workbook in this repo. Oh well.


### Testbench queries
Their name starts with `GQ_TB_`, and they're used to 
test results and performance. The two most important are:
* `GQ_TB_CoulAdj` to measure performance
* `GQ_TB_CompareTables` to test correctness

The other `TB` queries are mostly used to support the two above in a sensible
way.

### Documentation queries
Their name starts with `GQ_Doc_`, and I used them to verify the examples I
wrote in the user documentation.

# How to only read the code (with syntax colouring)
The queries are in `./src`, where `./` is the root of the git
repository, and where this `README.md` file is located.

## Visual Studio Code
1. Clone this repository
1. Install the [Power Query / M Language](https://marketplace.visualstudio.com/items?itemName=PowerQuery.vscode-powerquery)
extension
1. Enjoy 😊

## Power Query Formatter Website
1. Go to [https://www.powerqueryformatter.com/formatter](https://www.powerqueryformatter.com/formatter)
1. In the main area, copy-paste the code of the query you want to read.
1. Enjoy 😊

I am aware that this website may send my code to some servers for
processing or whatever. While I do prefer that you use Visual
Studio Code if you can, I care more about you not being or
feeling excluded because the only option I presented 
was my text editor of choice.



* Why public
* Legalese
* What (short~medium)
* Requirements
    * To read
    * To run
* Instructions
    * To read with syntax colouring
    * To import proprietary samples
    * To run
        * RepoRoot
        * Security warning?



