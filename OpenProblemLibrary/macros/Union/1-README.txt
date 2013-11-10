UNION-DEVELOPED MACRO FILES:

These are macro support files developed at Union College for use with
our problems.  There are a number of new answer checkers, some vector
routines, and some miscellaneous utilities.  Those whose names end in
Answer.pl are answer checkers, those ending in Grader.pl are graders,
and those ending in Utils.pl are collections of utilities.  Most of
the answer checkers are obsolete in light of the new MathObjects
library (developed at Union) that is now part of the main WeBWorK2
distribution, but are included here for compatibility with old problem
files that use them.  As we update the problems to use MathObjects,
these older macro files will be removed.

The file PGunion.pl includes most of the general utilities, but the
problems load the specific answer checkers and graders as needed.

The unionProblem.pl file implements a table that puts a border around
the main text of the problem and a background color that helps
separate the the problem from the rest of the text on the screen.
(See the comments in that file for details).  This is no longer
needed, as the global.conf file can be used to put in such borders
automatically.  The file no longer includes the borders by default
(since that meant that problems would get TWO borders).

All the files below contain comments that explain how to use them, so
check the individual files for details.  


  GENERAL UTILITIES:

    PGunion.pl            Simply includes a number of the other files
                          that make most of the union utilities available.

    PGcourse.pl           Empty, but allows course-by-course customization
                          of problems.  Should be loaded by all
                          problems as the LAST macro file loaded.

    PGstandard.pl         Just contains a bunch of loadMacros() calls
			  in order to make it easier to load the
			  standard ones without having to remember
			  them all.


    unionMacros.pl        Some extra macros like $BCENTER/$ECENTER and
                          so on that implement some additional HTML features.

    unionUtils.pl         Some miscellaneous sometimes-useful functions.

    unionProblem.pl       Implements the table around the main text of
			  the problem.  (Obsolete.)
    
    unionTables.pl	  Functions for creating tables and side-by-side
			  text.

    unionLists.pl	  Functions for creating UL and OL lists in
			  HTML, and corresponding lists in TeX mode.

    unionMessages.pl      Defines variables that hold standard
			  messages like how to enter "infinity", or
			  other such remarks.  This way they can be
			  guaranteed to be common from file to file,
			  and can be over-ridden on a course-by-course
			  basis.  (Using PGcourse.pl or a copy of this
			  file in the course's templates/macros directory.)



  IMAGE ROUTINES:

    unionImage.pl	  Implements an easier interface to including
			  images in your problems.

    LiveGraphics3D.pl	  Functions for including the LiveGraphics3D
			  Java applet into your problems.  (See below.)

    altPlotMacros.pl	  Some alternatives to the standard plot macros
			  that allows more sophisticated functions to
			  be called during graph creation.
			  (Obsolete: the plot macros now use MathObjects)

  ANSWER CHECKERS:

    Better versions of most of these are available as part of the new
    MathObjects library that is included with WeBWorK2.  See the
    documentation at http://wwebwork.maa.org/ and the various
    MathObjects extensions in pg/macros for more information.


    compositionAnswer.pl   An answer checker for function compositions.
			   (Obsolete: use pg/macros/answerComposition.pl)

    diffquotientAnswer.pl  An answer checker for difference quotients
			   where the student must reduce sufficiently
			   to remove the delta-x in the denominator.
			   (Obsolete: use pg/macros/parserDifferenceQuotient.pl)

    infiniteAnswer.pl	   An answer checker that handles numbers and
			   a variety of forms of infinity, including
			   -INF, which is not possible with the
			   current string/number checker.
			   (Obsolete: use MathObjects Infinity object)

    integerAnswer.pl       An answer checker that requires the student
			   to enter an integer.
			   (Obsolete: use MathObjects LimitedNumeric
			   context with NoDecimals)

    intervalAnswer.pl	   An answer checker for intervals (including
			   ones that have infinite endpoints).
			   Currently it doesn't do unions, but this
			   could be added.
			   (Obsolete: use MathObjects Interval and
			   Union objects)

    lineAnswer.pl	   An answer checker for parametric lines
			   given by a point and direction vector.  The
			   checker recognizes the line using any point
			   on the line, and any parallel vector.
			   (Obsolete: use pg/macros/parserParametricLine.pl)

    listAnswer.pl          Answer checkers for general lists of
			   items.  This is used as the basis of other
			   checkers, such as the vector and point
			   checkers.
			   (Obsolete: use MathObjects List object)

    parallelAnswer.pl	   An answer checker for a vector parallel to
			   a given vector, with an option of
			   specifying that the vector must be in the
			   same direcion (not the opposite direction).
			   (Obsolete: use MathObjects Vector object
			   with parallel=>1 option).

    planeAnswer.pl	   An answer checker for the implicit form of
			   a plane.  It will recognize the plane no
			   matter how it is entered, as long as it is
			   linear.
			   (Obsolete: use pg/macros/parserImplicitPlane.pl)

    pointAnswer.pl	   An answer checker that recognizes a point
			   or vector, either numeric or with equations
			   as its coordinates.
			   (Obsolete: use MathObjects Point object)

    unionAnswer.pl         Answer checker for unions of intervals.
			   (Obsolete: use MathObjects Union object)

    unorderedAnswer.pl	   A collection of routines that let the
			   student enter answers in any order.  For
			   example, you can ask "f(x) is defined
			   except for x = ___ and x = ___" and the
			   student can enter the answers in either
			   order.
			   (pg/macros/parserMultiAnswer.pl may be a
			   better alternative in some cases)

    variableAnswer.pl	   An answer checker for ordered or unordered
			   lists of comma- or space-separated words,
			   optionally enclosed in parentheses.  I used
			   it to ask for the names of the variables
			   used in multivariable functions, for
			   example.
			   (Obsolete:  use MathObjects List object in
			   String context)

    vectorAnswer.pl	   Alternative names for the routines in
			   pointAnswer.pl, which handles both points
			   and vectors.
			   (Obsolete: use MathObjects Vector object)

    answerUtils.pl	   General utility routines used by the
			   answer checkers above.
			   (MathObjects provide better alternatives.)


  GRADERS:

    weightedGrader.pl	  A grader that allows you to assign weights
			  to the various answers in a question, rather
			  than having them all equally weighted.  It
			  also provides the ability to have one answer
			  give credit for one or more other answer.


  MATCH-LIST ROUTINES:

    alignedChoice.pl	  A match-list subclass that uses tables to
			  create its question list.

    imageChoice.pl	  A match-list subclass that matches images
			  against the questions.  The images are
			  displayed in a table where you can specify
			  the number of columns, the sizes of the
			  images, and so on.

    choiceUtils.pl	  Contains an alternate print_q	 method that
			  uses tables to create the list of questions,
			  so that they will format better when a long
			  line wraps to the next line.


  VECTOR UTILITIES:

    Most of these are no longer needed, as their functionality has
    been incorporated into the MathObjects library.


    unionVectors.pl	  Implements a vector and point class that
			  lets you manipulate and display points and
			  vectors conveniently.  If used as a module,
			  it can overload the operators to make this
			  work even better, however that is not
			  required.
			  (Obsolete: this became the MathObjects
			  Vector object)

    vectorUtils.pl	  Some utilities for working with vectors.
			  (Obslete: use pg/macros/parserVectorUtils.pl)


  MISCELLANEOUS:

    unionInclude.pl	  Implements a simple means of including one
			  PG file into another (so that if several
			  problems use a common portion, it can be
			  kept in a single file that is included into
			  the individual problem files).  It also
			  implements a mechanism for creating problem
			  sets where the problems are presented in
			  random order.

    piecewiseFunctions.pl   Provides a means of producing piece-wise
			    defined functions that work for both TeX
			    and HTML modes from the same code.
			    (Obsolete: use pg/macros/contextPiecewiseFunction.pl)

    courseHeaders.pl	  A file that implements a standard header for
			  both paper and screen headers, so only one
			  file is needed for both.  This was not
			  really meant for distribution, but you might
			  find it useful anyway.  Note that it uses
			  Union-specific naming conventions for
			  courses, so can not be used directly by
			  other universities.


A NOTE ABOUT LIVEGRAPHICS3D:

LiveGraphics3D.pl requires the LiveGraphics3D applet to be available.
LiveGraphics3D.pl can be obtained from 

    http://wwwvis.informatik.uni-stuttgart.de/~kraus/LiveGraphics3D/

and is freely-distributable for non-commercial use.  Put the live.jar
file in your webwork2/htdocs/applets directory (you might need to
create one if it isn't there already), or in your course's
html/applets directory (again, it may need to be created).

Currently, LiveGraphics3D.pl only lets you load pre-created .m files,
but I have plans for a future class that will generate the Grpahics3D
object on the fly, just as 2D graphics are available now.  The
LiveGraphics3D format does allow for the file to include parameters
that are part of the applet call, so a single file can be used to
generate a different surface in a family of surfaces for each student,
for example.  There is also the possibility of interactive objects,
but I haven't experimented with these.
