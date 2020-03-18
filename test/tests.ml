open StdLabels
open Pp.O

let print pp = Format.printf "%a@." Pp.to_fmt pp

let many n pp = Array.make n pp |> Array.to_list |> Pp.concat ~sep:Pp.space

let xs n = many n (Pp.char 'x')

let ys n = many n (Pp.char 'y')

let%expect_test _ =
  let hello_xs n = Pp.text "Hello" ++ Pp.space ++ xs n in
  print (Pp.box ~indent:2 (hello_xs 200));
  [%expect
    {|
Hello x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x
  x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x
  x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x
  x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x
  x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x
  x x x x x x x x x x x x
|}];
  print (Pp.hbox (hello_xs 50));
  [%expect
    {|
Hello x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x
|}];
  print (Pp.vbox ~indent:2 (hello_xs 5));
  [%expect {|
Hello
  x
  x
  x
  x
  x
|}];
  print (Pp.hvbox ~indent:2 (hello_xs 5));
  [%expect {|
Hello x x x x x
|}];
  print (Pp.hvbox ~indent:2 (hello_xs 50));
  [%expect
    {|
Hello
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
  x
|}];
  print (Pp.hovbox ~indent:2 (hello_xs 200));
  [%expect
    {|
Hello x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x
  x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x
  x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x
  x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x
  x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x
  x x x x x x x x x x x x
|}]

(* Difference between box and hovbox *)
let%expect_test _ =
  let pp f = f (xs 50 ++ Pp.break ~nspaces:2 ~shift:(-1) ++ xs 10) in
  print (pp (Pp.box ~indent:2));
  [%expect
    {|
x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x
  x x x x x x x x x x x
 x x x x x x x x x x
|}];
  print (pp (Pp.hovbox ~indent:2));
  [%expect
    {|
x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x
  x x x x x x x x x x x  x x x x x x x x x x
|}]

let enum_x_and_y = Pp.enumerate [ xs; ys ] ~f:(fun f -> f 50)

let%expect_test _ =
  print enum_x_and_y;
  [%expect
    {|
- x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x
  x x x x x x x x x x x x
- y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y
  y y y y y y y y y y y y
|}]

let%expect_test _ =
  print
    (Pp.enumerate
       [ Pp.enumerate [ "abc"; "def" ] ~f:Pp.text; enum_x_and_y ]
       ~f:(fun x -> x));
  [%expect
    {|
- - abc
  - def
- - x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x
    x x x x x x x x x x x x x
  - y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y
    y y y y y y y y y y y y y
|}]

let%expect_test _ =
  print (Pp.verbatim "....." ++ Pp.box ~indent:2 (xs 50));
  [%expect
    {|
    .....x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x
           x x x x x x x x x x x x x x |}]
