#lang scribble/manual

@(require scribble/eval)
@(define my-eval (make-base-eval))


@title{Using Scribble Programatically}
@author+email["Danny Yoo" "dyoo@hashcollision.org"]


There are times when generating Scribble documentation through
the command line option doesn't provide fine-enough control over the output.
This quick guide shows how to generate Scribble documents programmatically
through pure Racket.

Much of this will reference the low-level API infrastructure in Scribble.


Let's say that we have a small document, like the following
@filebox["hello.scrbl"]{
@codeblock|{
#lang scribble/base
Hello @emph{beautiful} world!
            }|
}

When we invoke the @filepath["hello.scrbl"] module, it'll provide a @racket[doc]
binding that represents a decoded document, a @emph{part}.
Let's use @racket[dynamic-require] to look at this @racket[doc].
@interaction[#:eval my-eval
                    (define my-doc (dynamic-require "hello.scrbl" 'doc))
                    my-doc]

We can walk through this @emph{part} structure, using selectors such as @racket[part-blocks]:
@interaction[#:eval my-eval
                    (require scribble/core)
                    (part-blocks my-doc)]
It should be fairly easy to do some kind of automated processing on Scribble documents, as
they are structured values.


The most common operation we can perform on a part is to render it.  Let's render @filepath["hello.scrbl"]
to HTML.

@interaction[#:eval my-eval
                    (require scribble/render)
                    (render (list my-doc)
                            (list "hello.scrbl"))]

Ok, that was quiet.  What happened?

By default, the renderer generates HTML text in the form of
@filepath["sample-output.html"].  It also writes out auxiliary files,
such as @filepath["scribble.css"], in the current directory.


If we want to direct the output elsewhere, we'll want to use the [#:dest-dir]
option to @racket[render].  Let's do that next.
@interaction[#:eval my-eval
                    (render #:dest-dir "dest" (list my-doc) (list "hello.scrbl"))
                    (directory-list "dest")]
                    
                                                                  