#lang scribble/manual

@(require scribble/eval)
@(define my-eval (make-base-eval))


@title{Using Scribble Programatically}
@author+email["Danny Yoo" "dyoo@hashcollision.org"]


There are times when generating Scribble documentation through
the command line option doesn't provide fine-enough control over the output.
This quick guide shows how to generate Scribble documents programmatically
through pure Racket.


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
                    (require scribble/base)
                    (part-blocks my-doc)]

@margin-note{Subtle: note that, for this particular example, we also rip out the existing tags associated to the document.
Scribble uses tags to represent data such as cross-referencing between documents.
If we try to generate documentation simultaneously for @racket[my-doc] and @racket[my-updated-doc],
Scribble will get rightfully confused.  As an exercise, preserve the existing tags and try to @racket[render]
both documents at once: you should see warnings.}
Since the document is a structured value, it's amendable to functions that we can write to automatically
reprocess them if we choose to.  For example, let's add a new paragraph to the end of the document.
@interaction[#:eval my-eval
                    (define my-updated-doc
                      (struct-copy part my-doc
                        [tags (list)]
                        [blocks (append (part-blocks my-doc)
                                        (list (para "Here's something we added")))]))]



The most common operation we can perform on a part is to render it.  Let's render the original
document as well as our updated version of the document:

@interaction[#:eval my-eval
                    (require scribble/render)
                    (render (list my-doc my-updated-doc) 
                            (list "hello.scrbl" "updated-hello.scrbl"))]

Ok, that was quiet.  What just happened?

By default, the renderer generates HTML text, using filenames based
on the second list of paths we pass to @racket[render].  In this case, it
wrote out to @filepath["hello.html"] and @filepath["updated-hello.html"]
in the current directory.  
@racket[render] also writes out auxiliary files,
such as @filepath["scribble.css"], in the current directory too.


@margin-note{Don't try to control @racket[current-directory] directly, as Scribble itself
can muck with it throughout the rendering process.}
If we want to direct the output elsewhere, we'll want to use the @racket[#:dest-dir]
option to @racket[render].  Let's do that next.
@interaction[#:eval my-eval
                    (render #:dest-dir "dest"
                            (list my-doc my-updated-doc) 
                            (list "hello.scrbl" "updated-hello.scrbl"))
                    (directory-list "dest")]
There are the files that @racket[render] generated for us.

