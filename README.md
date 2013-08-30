Haskell Interpreter ("hint")
===

This is a GitHub mirror for Daniel Gorin's excellent [hint](http://hackage.haskell.org/package/hint) library, for those who, like me, are not familiar with darcs.

Installation
---

Hint is on hackage, so you don't need to checkout this repository in order to install it. Simply use `cabal` or `cabal-dev`, as usual.

    > cabal-dev install hint
    Registering hint-0.3.3.6...
    Installed hint-0.3.3.6

Usage
---

That's it! You can now use `eval` inside your Haskell programs. The `package-db` argument is only required if you used `cabal-dev`.

    > ghci -package-db="$(ls -d cabal-dev/packages-*.conf)"
    λ> import Language.Haskell.Interpreter
    λ> :{
    λ| runInterpreter $ do setImports ["Prelude"]
    λ|                     eval "2 + 2"
    λ| :}
    Right "4"

Development
---

If you want to make modifications to the source, then you do need this repository.

The sole purpose of this branch is to display this README file. To compile hint, you should instead checkout the `darcs_import` branch as follows.

    > git checkout darcs_import
    Switched to branch 'darcs_import'

You can then install the library using `cabal` or `cabal-dev`.

    > cabal-dev install
    Registering hint-0.3.3.6...
    Installed hint-0.3.3.6

