
# Using Plupload With Amazon S3 And Imgix In AngularJS

by [Ben Nadel][bennadel] (on [Google+][googleplus])

In most of my Plupload demos, I've been uploading images and then using the full size image to render
a "thumbnail"; but, now that I am learning about [Imgix][imgix], for on-demand image processing, I 
wanted to see if I could use Imgix to build on-the-fly thumbnails for my Plupload demos. So, in this
experiment, I am still uploading directly from Plupload to Amazon S3; but, when the thumbnails are
rendered, they will be routed through Imgix:

User -> Thumbnail Url -> Imgix Cache -> Imgix Processor -> Amazon S3 Pre-Signed Url

The power of Imgix isn't just that it can do the image processing, which means freeing your servers
up to do more "business stuff," it also means that we can change the thumbnail style and / or size
on the fly. Pretty crazy awesome if you ask me!


[bennadel]: http://www.bennadel.com
[googleplus]: https://plus.google.com/108976367067760160494?rel=author
[plupload]: http://plupload.com
[imgix]: http://imgix.com
[angularjs]: http://angularjs.org
