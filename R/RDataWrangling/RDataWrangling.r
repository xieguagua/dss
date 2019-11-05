# **Topics**
#
# * Iterating over files
# * Filtering with regular expressions (regex)
# * Writing your own functions
# * Reshaping data
# * Loading Excel worksheets

# ## Setup 
#
# ### Software & materials
#
# You should have R and RStudio installed --- if not:
#
# * Download and install R: <http://cran.r-project.org>
# * Download and install RStudio: <https://www.rstudio.com/products/rstudio/download/#download>
#
# Download materials:
#
# * Download class materials at <https://github.com/IQSS/dss-workshops-redux/raw/master/R/RDataWrangling.zip>
# * Extract materials from the zipped directory `RDataWrangling.zip` (Right-click => Extract All on Windows, double-click on Mac) and move them to your desktop!
#
# Start RStudio and create a new project:
#
# * On Windows click the start button and search for RStudio. On Mac
#     RStudio will be in your applications folder.
# * In Rstudio go to `File -> New Project`.
# * Choose `Existing Directory` and browse to the `RDataWrangling` directory.
# * Choose `File -> Open File` and select the blank version of the `.Rmd` file.
#
# While R's built-in packages are powerful, in recent years there has
# been a big surge in well-designed *contributed packages* for R. 
# In particular, a collection of R packages called 
# [tidyverse](https://www.tidyverse.org/) have been 
# designed specifically for data science. All packages included in 
# `tidyverse` share an underlying design philosophy, grammar, and 
# data structures. We will use `tidyverse` packages throughout the 
# workshop, so let's install them now:

#install.packages("tidyverse")
library(tidyverse)
library(readxl) # installed with tidyverse

# We can also install the `rmarkdown` package, which will allow us to
# combine our text and code into a formatted document at the end of 
# the workshop:

# install.packages("rmarkdown")
library(rmarkdown)


# ### Goals
#
# Class Structure and Organization:
#
# * Ask questions at any time. Really!
# * Collaboration is encouraged - please spend a minute introducing yourself to your neighbors!
#
# This is an intermediate R course:
#
# * Assumes working knowledge of R
# * Relatively fast-paced
# * Data scientists are known and celebrated for modeling and visually
# displaying information, but down in the data science engine room there
# is a lot of less glamorous work to be done. Before data can be used
# effectively it must often be cleaned, corrected, and reformatted. This
# workshop introduces the basic tools needed to make your data behave,
# including data reshaping, regular expressions and other text
# manipulation tools.

# ## Example project
#
# It is common for data to be made available on a website somewhere, either by a
# government agency, research group, or other organizations and entities. Often
# the data you want is spread over many files, and retrieving it all one file at a
# time is tedious and time consuming. Such is the case with the baby names data we
# will be using today.
#
# The UK [Office for National Statistics](https://www.ons.gov.uk) provides yearly
# data on the most popular baby names going back to 1996. The data is provided
# separately for boys and girls and is stored in Excel spreadsheets.
#
# I have downloaded all the excel files containing boys names data from
# https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/livebirths/datasets/babynamesenglandandwalesbabynamesstatisticsboys 
# and made them available at 
# http://tutorials.iq.harvard.edu/R/RDataManagement/data/boysNames.zip.
#
# Our mission is to extract and graph the **top 100** boys names in England
# and Wales for every year since 1996. There are several things that
# make this challenging.
#
# ### Problems with the data
#
# While it was good of the UK Office for National Statistics to provide
# baby name data, they were not very diligent about arranging it in a
# convenient or consistent format.

# ## Exercise 0
#
# Our mission is to extract and graph the **top 100** boys names in England and Wales for every year since 1996. There are several things that make this challenging.
#
# 1.  Locate the file named `1996boys_tcm77-254026.xlsx` and open it in
#     a spreadsheet. (If you don't have a spreadsheet program installed on
#     your computer you can downloads one from
#     https://www.libreoffice.org/download/download/). What issues can you
#     identify that might make working with these data more difficult?
#
# 2.  Locate the file named `2015boysnamesfinal.xlsx` and open it in a
#     spreadsheet. In what ways is the format different than the format
#     of `1996boys_tcm77-254026.xlsx`? How might these differences make
#     it more difficult to work with these data?

# ## Working with Excel worksheets
#
# As you can see, the data is in quite a messy state. Note that this is
# not a contrived example; this is exactly the way the data came to us
# from the UK government website! Let's start cleaning and organizing
# it. 
#
# Each Excel file contains a worksheet with the baby names data we want.
# Each file also contains additional supplemental worksheets that we are
# not currently interested in. As noted above, the worksheet of interest
# differs from year to year, but always has "Table 1" in the sheet name.
#
# The first step is to get a vector of file names.

boy_file_names <- list.files("dataSets/boys", full.names = TRUE)

# Now that we've told R the names of the data files we can start working
# with them. For example, the first file is

boy_file_names[1]

# and we can use the `excel_sheets()` function from the `readxl` package
# within `tidyverse` to list the worksheet names from this file.

excel_sheets(boy_file_names[1])

# ### Iterating over file names with `map()`
#
# Now that we know how to retrieve the names of the worksheets in an
# Excel file we could start writing code to extract the sheet names from
# each file, e.g.,

excel_sheets(boy_file_names[1])

excel_sheets(boy_file_names[2])

## ...
excel_sheets(boy_file_names[20])


# This is not a terrible idea for a small number of files, but it is
# more convenient to let R do the iteration for us. We could use a `for loop`,
# or `sapply()`, but the `map()` family of functions from the `purrr`
# package within `tidyverse` gives us a more consistent alternative, 
# so we'll use that.

map(boy_file_names, excel_sheets)
# map(thing to iterate over, task to do in each iteration)

# ### Filtering strings using regular expressions
#
# In order to extract the correct worksheet names we need a way to extract
# strings containing "Table 1". Base R provides some string manipulation
# capabilities (see `?regex`, `?sub` and `?grep`), but we will use the
# *stringr* package because it is more user-friendly.
#
# The `stringr` package within `tidyverse` provides functions to *detect*, 
# *locate*, *extract*, *match*, *replace*, *combine* and *split* strings 
# (among other things). 
#
# Here we want to detect the pattern "Table 1", and only
# return elements with this pattern. We can do that using the
# `str_subset()` function. The first argument to `str_subset()` is character
# vector we want to search in. The second argument is a *regular
# expression* matching the pattern we want to retain.
#
# If you are not familiar with regular expressions, <http://www.regexr.com/> is a
# good place to start.
#
# Now that we know how to filter character vectors using `str_subset()` we can
# identify the correct sheet in a particular Excel file. For example,

#str_subset(excel_sheets(boy_file_names[1]), pattern = "Table 1")
excel_sheets(boy_file_names[1]) %>% str_subset(pattern = "Table 1")

# ### Writing your own functions
#
# The `map*` functions are useful when you want to apply a function to get a
# list or vector of inputs and obtain the return values. This is very
# convenient when a function already exists that does exactly what you
# want. In the examples above we mapped the `excel_sheets()` function to
# the elements of a vector containing file names. But now there is no
# function that both retrieves worksheet names and subsets them.
# Fortunately, writing functions in R is easy.

# anatomy of a function

# function_name <- function(arg1, arg2, ....) {
#  
#   # body of function - where stuff happens #
#
#   return( results ) 
# }

get_data_sheet_name <- function(file, term){
  excel_sheets(file) %>% str_subset(pattern = term)
}

# the goal is generalization 
get_data_sheet_name(anyfile)
get_data_sheet_name(anyfile, term="Table 2")


# Now we can map this new function over our vector of file names.

map(boy_file_names,
    get_data_sheet_name,
    term = "Table 1")

# ## Reading Excel data files
#
# Now that we know the correct worksheet from each file we can actually
# read those data into R. We can do that using the `read_excel()`
# function.
#
# We'll start by reading the data from the first file, just to check
# that it works. Recall that the actual data starts on row 7, so we want
# to skip the first 6 rows. We can use the `glimpse()` function from
# the `dplyr` package within `tidyverse` to view the output.

tmp <- read_excel(
  path = boy_file_names[1],
  sheet = get_data_sheet_name(boy_file_names[1],
                              term = "Table 1"),
  skip = 6
)

glimpse(tmp)

# ## Exercise 1
#
#   1. Write a function that takes a file name as an argument and reads
#      the worksheet containing "Table 1" from that file. Don't forget
#      to skip the first 6 rows.
## 

#   2. Test your function by using it to read *one* of the boys names
#      Excel files.
## 

#   3. Use the `map()` function to read data from all the Excel files,
#      using the function you wrote in step 1.
## 


# ## Data cleanup
#
# Now that we've read in the data we still have some cleanup to do.
# Specifically, we need to:
#
# 1. fix column names
# 2. get rid of blank row and the top and the notes at the bottom
# 3. get rid of extraneous "changes in rank" columns if they exist
# 4. transform the side-by-side tables layout to a single table.
#
# In short, we want to go from this:
#
# ![messy](R/RDataWrangling/images/messy.png)
#
# to this:
#
# ![tidy](R/RDataWrangling/images/clean.png)
#
# There are many ways to do this kind of data manipulation in R. We're
# going to use the `dplyr` and `tidyr` packages from within `tidyverse`
# to make our lives easier.

# ### Selecting columns
#
# Next we want to retain just the `Name...2`, `Name...6`, `Count...3` and `Count...7` columns. We can do that using the `select()` function:

boysNames[[1]]

boysNames[[1]] <- select(boysNames[[1]], Name...2, Name...6, Count...3, Count...7)
boysNames[[1]]

# Why are we using **double brackets** `[[` to index this list object?
#
# ![list indexing](R/RDataWrangling/images/indexing_lists.png)

# ### Dropping missing values
#
# Next we want to remove blank rows and rows used for notes. An easy way
# to do that is to use `drop_na()` from the `tidyr` package within `tidyverse`
# to remove rows with missing values.

boysNames[[1]]

boysNames[[1]] <- boysNames[[1]] %>% drop_na()

boysNames[[1]]

# Finally, we will want to filter out missing. Do this for all the
# elements in `boysNames`, a task I leave to you.

# ## Exercise 2
#
#   1. Write a function that takes a `data.frame` as an argument and
#      returns a modified version including only columns named `Name...2`,
#      `Name...6`, `Count...3`, and `Count...7`. 
## 

#   2. Test your function on the first `data.frame` in the list of baby
#      names data.
## 

#   3. Use the `map()` function to each `data.frame` in the list of baby
#      names data.
## 


# ### Re-arranging into a single table
#
# Our final task is to re-arrange the data so that it is all in a single
# table instead of in two side-by-side tables. For many similar tasks
# the `gather()` function in the `tidyr` package is useful, but in this
# case we will be better off using a combination of `select()` and
# `bind_rows()`.

boysNames[[1]]
bind_rows(select(boysNames[[1]], Name = Name...2, Count = Count...3),
          select(boysNames[[1]], Name = Name...6, Count = Count...7))


# ## Exercise 3
#
# **Cleanup all the data**
#
# In the previous examples we learned how to drop empty rows with
# `drop_na()`, select only relevant columns with `select()`, and re-arrange
# our data with `select()` and `bind_rows()`. In each case we applied the
# changes only to the first element of our `boysNames` list.
#
# 1.  Your task now is to use the `map()` function to apply each of these
# transformations to all the elements in `boysNames`.
## 


# ## Data organization & storage
#
# Now that we have the data cleaned up and augmented, we can turn our attention to organizing and storing the data.

# ### One table for each year
#
# Right now we have a list of tables, one for each year. This is not a bad way to go. It has the advantage of making it easy to work with individual years; it has the disadvantage of making it more difficult to examine questions that require data from multiple years. To make the arrangement of the data clearer it helps to name each element of the list with the year it corresponds to.

glimpse(boysNames) %>% head()

Years <- str_extract(boy_file_names, pattern = "[0-9]{4}")
boysNames <- setNames(boysNames, Years)
glimpse(boysNames) 


# ### One big table
#
# While storing the data in separate tables by year makes some sense,
# many operations will be easier if the data is simply stored in one big
# table. We've already seen how to turn a list of data.frames into a
# single data.frame using `bind_rows()`, but there is a problem; The year
# information is stored in the names of the list elements, and so
# flattening the tables into one will result in losing the year
# information! Fortunately it is not too much trouble to add the year
# information to each table before flattening.

year_column <- function(data, name) {
  mutate(data, year = as.integer(name))
}

boysNames <- imap(boysNames, year_column)

boysNames[1]

boysNames <- bind_rows(boysNames)
glimpse(boysNames)

# ## Exercise 4
#
# **Make one big table**
#
# 1.  Turn the list of boys names data.frames into a single table. 
## 

# 2.  Create a directory under `data/all` and write the data to a `.csv`
# file.
## 

# 3.  Finally, repeat the previous exercise, this time working with the data
# in one big table.
## 


# ## Exercise solutions
#
# ### Ex 0: prototype
#
# > 1.  Locate the file named `1996boys_tcm77-254026.xlsx` and open it in
# >     a spreadsheet. (If you don't have a spreadsheet program installed on
# >     your computer you can downloads one from
# >     https://www.libreoffice.org/download/download/). What issues can you
# >     identify that might make working with these data more difficult?
#
# The data does not start on row one. Headers are on row 7, followed by
# a blank line, followed by the actual data.
#
# The data is stored in an inconvenient way, with ranks 1-50 in the
# first set of columns and ranks 51-100 in a separate set of columns.
#
# There are notes below the data.
#
# > 2.  Locate the file named `2015boysnamesfinal.xlsx` and open it in a
# >     spreadsheet. In what ways is the format different than the format
# >     of `1996boys_tcm77-254026.xlsx`? How might these differences make
# >     it more difficult to work with these data?
#
# The worksheet containing the data of interest is in different
# positions and has different names from one year to the next. However,
# it always includes "Table 1" in the worksheet name.
#
# Some years include columns for "changes in rank", others do not.
#
# These differences will make it more difficult to automate
# re-arranging the data since we have to write code that can handle
# different input formats.

# ### Ex 1: prototype

  ## 1. Write a function that takes a file name as an argument and reads
  ##    the worksheet containing "Table 1" from that file.
 
read_baby_names <- function(file) {
  read_excel(
    path = file,
    sheet = get_data_sheet_name(file, 
                                term = "Table 1"),
    skip = 6
  )
}
  
  ## 2. Test your function by using it to read *one* of the boys names
  ##    Excel files.

glimpse(read_baby_names(boy_file_names[1]))

  ## 3. Use the `map` function to read data from all the Excel files,
  ##    using the function you wrote in step 1.

boysNames <- map(boy_file_names, read_baby_names)


# ### Ex 2: prototype

  ## 1. Write a function that takes a `data.frame` as an argument and
  ##    returns a modified version including only columns named `Name...2`,
  ##    `Name...6`, `Count...3`, or `Count...7`.

  namecount <- function(data) {
      select(data, matches("Name|Count"))
  }
     
  ## 2. Test your function on the first `data.frame` in the list of baby
  ##    names data.

  namecount(boysNames[[1]])
  
  ## 3. Use the `map` function to each `data.frame` in the list of baby
  ##    names data.

  babyNames <- map(boysNames, namecount)

# ### Ex 3: prototype
#
# There are different ways you can go about it. Here is one:
#

## 1.  write a function that does all the cleanup
cleanupNamesData <- function(file){
  selected <- file %>%
    drop_na(Name...2) %>%
    select(matches("Name|Count"))
   
  bind_rows(select(selected, Name = Name...2, Count = Count...3),
            select(selected, Name = matches("Name...6|Name...7|Name...8"),
                             Count = matches("Count...7|Count...8|Count...9")
                   ))
}


## test it out on the second data.frame in the list
glimpse(boysNames[[2]]) # before cleanup
glimpse(cleanupNamesData(boysNames[[2]])) # after cleanup

## apply the cleanup function to all the data.frames in the list
boysNames <- map(boysNames, cleanupNamesData)

# ### Ex 4: prototype
#
# Working with the data in one big table is often easier.

## 1.  Turn the list of boys names data.frames into a single table.

boysNames <- bind_rows(boysNames)

## 2.  Create a directory under `dataSets/all` and write the data to a `.csv`
file.

dir.create("dataSets/all")

write_csv(boysNames, "dataSets/all/boys_names.csv")


## 3.  Finally, repeat the previous exercise, this time working with the data
in one big table.
## What were the five most popular names in 2013?

boysNames %>% 
  filter(year == 2013) %>%
  arrange(desc(Count)) %>%
  slice(1:5)

## How has the popularity of the name "ANDREW" changed over time?
andrew <- filter(boysNames, Name == "ANDREW")

ggplot(andrew, aes(x = year, y = Count)) +
    geom_line() +
    ggtitle("Popularity of \"Andrew\", over time")


# ## Wrap-up
#
# ### Feedback
#
# These workshops are a work in progress, please provide any feedback to: help@iq.harvard.edu
#
# ### Resources
#
# * IQSS 
#     + Workshops: <https://dss.iq.harvard.edu/workshop-materials>
#     + Data Science Services: <https://dss.iq.harvard.edu/>
#     + Research Computing Environment: <https://iqss.github.io/dss-rce/>
#
# * HBS
#     + Research Computing Services workshops: <https://training.rcs.hbs.org/workshops>
#     + Other HBS RCS resources: <https://training.rcs.hbs.org/workshop-materials>
#     + RCS consulting email: <mailto:research@hbs.edu>
#     
# * R
#     + Learn from the best: <http://adv-r.had.co.nz/>; <http://r4ds.had.co.nz/>
#     + R documentation: <http://cran.r-project.org/manuals.html>
#     + Collection of R tutorials: <http://cran.r-project.org/other-docs.html>
#     + R for Programmers (by Norman Matloff, UC--Davis) <http://heather.cs.ucdavis.edu/~matloff/R/RProg.pdf>
#     + Calling C and Fortran from R (by Charles Geyer, UMinn) <http://www.stat.umn.edu/~charlie/rc/>
#     + State of the Art in Parallel Computing with R (Schmidberger et al.) <http://www.jstatso>|.org/v31/i01/paper
#
#
