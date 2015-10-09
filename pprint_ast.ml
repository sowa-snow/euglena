open Ast

let ty fmt t =
  let subst = ref [] and counter = ref 0 in
  let rec iter weak t =
    match t.t_desc with
    | Ty_var x ->
      let x = begin try List.assoc t !subst with Not_found ->
        let v = Char.escaped (char_of_int ((Char.code 'a') + !counter mod 26)) in
        subst := (t, v) :: !subst;
        incr counter;
        v
      end in
      if t.t_level = Types.generalize_level then
        Format.fprintf fmt "'%s" x
      else
        Format.fprintf fmt "'_%s" x
    | Ty_const x ->
      Format.fprintf fmt "%s" x
    | Ty_fun (t1, t2) ->
      if weak then Format.fprintf fmt "(";
      iter true t1;
      Format.fprintf fmt " -> ";
      iter false t2;
      if weak then Format.fprintf fmt ")"
    | Ty_link t ->
      iter weak t
    | Ty_subst _ ->
      assert false
  in
  iter false t

let pattern fmt pat =
  let rec iter weak pat =
    if weak then Format.fprintf fmt "(";
    begin match pat.p_desc with
    | Pat_var x ->
      begin match pat.p_ty with
      | Some t ->
        Format.fprintf fmt "%s : %a" x ty t
      | None ->
        Format.fprintf fmt "%s" x
      end
    | Pat_annot (p, _) ->
      iter false p
    end;
    if weak then Format.fprintf fmt ")"
  in
  iter true pat

let expression fmt expr =
  let rec iter n fmt expr =
    match expr.e_desc with
    | Expr_let (is_rec, p, e1, e2) ->
      Format.fprintf fmt "let%s %a =@ %a in@ %a"
        (if is_rec then " rec" else "")
        pattern p
        (iter 0) e1
        (iter 0) e2
    | Expr_if (e1, e2, e3) ->
      Format.fprintf fmt "if %a@ then %a@ else%a"
        (iter 0) e1
        (iter 0) e2
        (iter 0) e3
    | Expr_fun (p, e) ->
      Format.fprintf fmt "fun %a ->@ %a"
        pattern p
        (iter 0) e
    | Expr_app (e1, e2) ->
      Format.fprintf fmt "%a %a"
        (iter 0) e1
        (iter 0) e2
    | Expr_var x ->
      Format.fprintf fmt "%s" x
    | Expr_int i ->
      Format.fprintf fmt "%d" i
    | Expr_bool b ->
      Format.fprintf fmt "%b" b
  in
  iter 0 fmt expr

let top_phrase fmt top =
  match top.tp_desc with
  | Top_let (is_rec, p, e) ->
    Format.fprintf fmt "let%s %a =@ %a;;"
      (if is_rec then " rec" else "")
      pattern p
      expression e
  | Top_expr e ->
    Format.fprintf fmt "%a;;"
      expression e
