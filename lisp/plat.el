(pcase system-type
  ('gnu/linux (load "plat/linux"))
  ('darwin (load "plat/darwin")))
