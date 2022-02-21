datatype Tree<T> = Leaf | Node(Tree<T>, Tree<T>, T)
datatype List<T> = Nil | Cons(T, List<T>)

function flatten<T>(tree:Tree<T>):List<T>
{
	match tree
    case Leaf => Nil
    case Node(t1, t2, p) => Cons(p, append(flatten(t1), flatten(t2)))
}

function append<T>(xs:List<T>, ys:List<T>):List<T>
{
	match xs
    case Nil => ys
    case Cons(p, ps) => Cons(p, append(ps, ys))
}

function treeContains<T>(tree:Tree<T>, element:T):bool
{
	match tree
    case Leaf => false
    case Node(t1, t2, p) => (p == element) || treeContains(t1, element) || treeContains(t2, element)
}

function listContains<T>(xs:List<T>, element:T):bool
{
  match xs
    case Nil => false
    case Cons(p, ps) => (p == element) || listContains(ps, element)
}

lemma sameElementsAppend<T>(xs:List<T>, ys:List<T>, element:T)
ensures listContains(append(xs, ys), element) <==> listContains(xs, element) || listContains(ys, element)
{
  match xs
    case Nil => {}
    case Cons(p, ps) => {
      sameElementsAppend(ps, ys, element);
      assert append(Cons(p, ps), ys) == Cons(p, append(ps, ys));
      assert listContains(append(xs, ys), element)
          == listContains(append(Cons(p, ps), ys), element)
          == listContains(Cons(p, append(ps, ys)), element)
          == (p == element) || listContains(append(ps, ys), element)
      ;
    }
}

lemma sameElements<T>(tree:Tree<T>, element:T)
ensures treeContains(tree, element) <==> listContains(flatten(tree), element)
{
	match tree
    case Leaf => {
      assert treeContains(tree, element)
        <==> treeContains(Leaf, element)
        <==> false
        <==> listContains(Nil, element)
        <==> listContains(flatten(Leaf), element)
        <==> listContains(flatten(tree), element)
      ;
    }
    case Node(t1, t2, p) => {
      sameElements(t1, element);
      sameElements(t2, element);
      sameElementsAppend(flatten(t1), flatten(t2), element);
      assert treeContains(tree, element)
        <==> treeContains(Node(t1, t2, p), element)
        <==> (p == element) || treeContains(t1, element) || treeContains(t2, element)
        <==> (p == element) || listContains(flatten(t1), element) || listContains(flatten(t2), element)
        <==> (p == element) || listContains(append(flatten(t1), flatten(t2)), element)
        <==> listContains(Cons(p, append(flatten(t1), flatten(t2))), element)
        <==> listContains(flatten(Node(t1, t2, p)), element)
        <==> listContains(flatten(tree), element)
      ;
    }
}
