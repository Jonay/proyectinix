Tog Forum: a work in progress
========

Tog forums support: not ready for prime time! 
I started working on this but it is not yet complete. I realize that the model Post conflicts with a Post model in tog_conversatio. I'll fix it when I can, but in the meantime, if you really need it fixed, you can always fork this project :)

Included functionality
-----------------------

* Forum, topics and posts
* Customizable access control (login required)
* Integration with authentication_system via tog_user
* Administration interface (utilizing existing admin? rules in tog_user)

Resources
=========

Plugin requirements
-------------------
* tog_user
* will_paginate (as gem)
* white_list_model


Install
-------

<pre>
rake rails:template LOCATION=http://tr.im/aspgems_tog_forum
</pre>

More
-------

[http://github.com/jacqui/tog_forum](http://github.com/jacqui/tog_forum)


Copyright (c) 2008 Jacqui Maher, released under the MIT license
