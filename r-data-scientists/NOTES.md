# R for Data Scientists
---

  - from [here](http://r4ds.had.co.nz/introduction.html)

## 1. (Book) Introduction

  - Import -> tidy -> (Transform, Visualize, Model) => Communicate
  - **wrangling** - creating new variables from existing, standardizing, etc
  - knowledge generation comes from **visualization** and **modeling**
  - **viz**: inherently human, should contain some amount of surprise, raise new questions, highlight that we're asking wrong questions, etc
  - **models**: after making sufficiently precise questions, use model to answer them. Always have assumptions, something to watch
  - This book is *not* big data - but sometimes, Big Data is actually regular data in disguise: do you really need all 5Tb to answer some modelling questions, or will correct sampling get you 95% of the way there?
  - This book focuses on **hypothesis generation** (aka data exploration) and not on *hypothesis confirmation*

# I: Explore
---
## 2. (Explore) Intro
  - Viz, Transform, EDA (Exploratory Data Analysis)

## 3. Data Visualization
  - Sample plotting code:
    
    ```r
    ggplot(data=mpg) +
     geom_point(mapping=aes(x=displ, y=hwy))
    ```
    *mapping* data elements into visual spaces *aes*-thetically
  - **NB**: not completely object-oriented, e.g. `nrow(<DATA>)` and `ncol(<DATA>)`
  - Random sidenote: `na.omit(<DATA>)` or `complete.cases(<DATA>)`
  - § 3.2.4 Exercise 5: Why's scatterplot of `mpg$class` vs `mpg$drv` not useful?
    - Because they're categorical, so you can't draw any lines. `frontwheel` drive is neither above nor below `4-wheel drive`.
    - Also, lack of jitter means we don't even know the concentrations (though, I'd argue that if we did have a little jitter, or if say, all `front wheel drive` were `midsize` while all `4 wheel` were `pickup`, we *would* learn something interesting... it just may not be the best medium to determine such relationships)
  - Additional levels in `ggplot aes` include:
    - `color` (categorical is clearer, continuous makes heatmaps)
    - `size` (should be ordered aesthetic, not categorical)
    - `alpha` (transparency)
    - `shape` (max 6)
  - aesthetics can take a column, or what amount to a lambda, e.g. `color=mpg<20` will split into true and false colors
  - `facet_wrap()` will, in a sense, make an aesthetic out of the categories, making `n` subplots. But, it doesn't go *in* the `aes()`, it gets added after.
  - `facet_grid()` takes 2 args to make an `x ~ y` set of subplots, generally for splitting out whatever graph by 2 categorical variables. If some `x ~ y` combo doesn't exist, that subplot will be empty, unsurprisingly.
    - to get `facet_grid()`-type results but only for one categorical variable, use `.` as other arg: `... + facet_grid(. ~ hwy)` or `... + facet_grid(hwy ~ . )`
  - hmm. so, `facet_wrap()` can take multiple variables, like `facet_wrap(~ class + drv)` and this will plot only the existing combinations, rather than the rectangular `facet_grid(class ~ drv)` which may have lots of empty grids.
  - `geom_point()` also has multiple levels
    - `point` (scatterplot) (and `geom_jitter`)
    - `smooth` (smoothed regression line with error bars)
    - `line`
    - `boxplot`
    - etc.
  - `geom_smooth()` - doesn't make sense to take the `shape` aesthetic, but it can take, e.g. `linetype`
  - You can add two `geom_*()` together to overlay them; if they all use the same set of variables for certain levels, you can move the mapping into the `ggplot()` call:
    
    ```r
    ggplot(data=mpg, mapping=aes(x=displ, y=hwy, color=factor(cyl))) +
     geom_point() + geom_smooth()
    ```
  - can set `data` inside a particular `geom_*` - useful when overlaying multiple geoms. And `data` can take the output of `filter(...)` (like Python's `df[df.foo > 10]` kinda filter)
  - with things like `geom_bar()`, it does the counts for you, guessing at the bins. Categorical is straightforward.
  - `position` is a `geom_*()` argument that helps define how to manage multiple sets of values within that `geom`. This is where `jitter` comes in, but also things like `dodge` (break apart `bar` chart by some `y` variable and stack all next to each other)
    - `jitter`, `dodge`, `fill`, `identity`, `stack`

## 5. Data Transformation
mostly using `dplyr` functions here:

  - `filter()` - grabbing subsets of rows, where some condition is met
  - `arrange()` - order the rows (`na` at the end, whether ascending or `desc(<condition>)`)
  - `select()` - grab only specific columns
    - `one_of()`, `everything()`, listed names, `matches()`, `starts_with()`, `ends_with()`, `contains()`
  - `mutate()` - creates **new** df with new column(s) appended. New columns can refer to earlier-defined new columns as well.
  - `summarise()`
  - *pipes* (`%>%`) make the code clearer than nesting. Compare:
  
    ```r
    arrange(
      summarize(
        group_by(flights, carrier),
        delay=mean(dep_delay, na.rm=TRUE)),
      desc(delay))
    ```
    with:
    
    ```r
    flights %>%
     group_by(carrier) %>%
     summarize(
       delay=mean(dep_delay, na.rm=TRUE)
     ) %>%
     arrange(desc(delay))
    ```

## 7: EDA

  - What type of variation within a variable?
  - What type of covariation among variables?

  - `geom_bar()`
  - `geom_histogram(binwidth=<N>)`
  - `geom_freqpoly(binwidth=<N>)` for "overlapping" histograms

## 12: Tidy Data
  - `gather()` converts multipe columns into 1 (categorically) - makes more rows
  - `spread()` splits one column into many (categorically) - makes fewer rows
  - `separate()` splits one column into many (regex-ically) - keeps same number of rows
  - `unite()` concatenates multiple columns into 1 - keeps same number of rows
  - `complete()` - creates more rows if necessary to have every `(x, y)` combination