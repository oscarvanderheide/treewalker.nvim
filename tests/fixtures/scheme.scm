(define (permutations lst)
  (if (null? lst)
      '(())
      (append-map (lambda (x)
                     (map (lambda (y) (cons x y))
                          (permutations (remove x lst))))
                 lst)))

