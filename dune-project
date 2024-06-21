(lang dune 3.5)

(generate_opam_files true)

(formatting
 (enabled_for dune))

(name lwd)

(source
 (github let-def/lwd))

(license MIT)

(authors "Frédéric Bour")

(maintainers "fred@tarides.com")

(package
 (name lwd)
 (synopsis "Lightweight reactive documents")
 (documentation "https://let-def.github.io/lwd/doc")
 (depends
  dune
  seq
  (ocaml
   (>= "4.03"))
  (qtest :with-test)
  (qcheck :with-test)))

(package
 (name nottui)
 (synopsis "UI toolkit for the terminal built on top of Notty and Lwd")
 (documentation "https://let-def.github.io/lwd/doc")
 (depends
  (lwd
   (= :version))
  (notty
   (>= 0.2))
  (cbor :with-test) ; for the examples
  (containers :with-test)))

; for the examples

(package
 (name nottui-pretty)
 (synopsis "A pretty-printer based on PPrint rendering UIs")
 (documentation "https://let-def.github.io/lwd/doc")
 (depends
  (nottui
   (= :version))
  (notty
   (>= 0.2))))

(package
 (name nottui-lwt)
 (synopsis "Run Nottui UIs in Lwt")
 (documentation "https://let-def.github.io/lwd/doc")
 (depends
  lwt
  (nottui
   (= :version))
  (notty
   (>= 0.2))))
