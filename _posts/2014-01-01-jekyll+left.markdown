---
layout: post
title: Jekyll + Left  
category: posts
---

Trying out jekyll and Left for a simple place to keep development
notes and articles. Jekyll is a static site generator written in
ruby. It allows one to write posts in a some variant of markdown
allowing for easier generation static content. While left is a jekyll
theme authored by Zach Holman. The combination seems to work quite
well.


For displaying mathematical formulas we try mathjax. Code highlighting
comes bundled with Jekyll.

*Euler's Formual:*
$$e^{ \pm i\theta } = \cos \theta \pm i\sin \theta$$

*Ruby moo* 
{% highlight ruby %}
def foo
  puts 'moo'
end
{% endhighlight %}

*Java moo*
{% highlight java %}
public static void main (String[] args){
    System.out.println("moo");
}
{% endhighlight %}

*Python moo*

{% highlight python %}
def moo:   
   print "moo";
{% endhighlight %}

*Bash moo*
{% highlight bash %}
echo "moo";
{% endhighlight %}



--- 
For those interested in a similar setup checkout the githup
repositories of Jekyll and Left available [here][jekyll] and
[here][left].


[jekyll]: https://github.com/mojombo/jekyll
[left]: https://github.com/holman/left#readme
