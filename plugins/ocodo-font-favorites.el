(defun ocodo/font-favorites ()
  "Set default and variable-pitch fonts from favorites."
  (interactive)
  (let* ((default-mono-fonts '(("PFDin Mono XThin"             (:family "PFDinMono-XThin" :weight normal))
                               ("PFDin Mono Thin"              (:family "PFDinMono-Thin" :weight normal))
                               ("PFDin Mono Light"             (:family "PFDinMono-Light" :weight normal))
                               ("SauceCodePro Nerd ExtraLight" (:family "SauceCodePro Nerd Font" :weight light))
                               ("SauceCodePro Nerd Light"      (:family "SauceCodePro Nerd Font" :weight semi-light))
                               ("SauceCodePro Nerd Regular"    (:family "SauceCodePro Nerd Font" :weight normal))
                               ("Input Mono Regular"           (:family "Input Mono" :weight normal))
                               ("Input Mono Light"             (:family "Input Mono" :weight semi-light))
                               ("APL385 Unicode"               (:family "APL385 Unicode" :weight normal))
                               ("IBM Plex Mono Thin"           (:family "IBM Plex Mono" :weight ultra-light))
                               ("IBM Plex Mono ExtraLight"     (:family "IBM Plex Mono" :weight light))
                               ("IBM Plex Mono Light"          (:family "IBM Plex Mono" :weight semi-light))
                               ("IBM Plex Mono Regular"        (:family "IBM Plex Mono" :weight normal))))
         (variable-pitch-fonts '(("Helvetica Neue Regular"       (:family "Helvetica Neue" :weight normal))
                                 ("Helvetica Neue Light"         (:family "Helvetica Neue" :weight light))
                                 ("Helvetica Neue Ultralight"    (:family "Helvetica Neue" :weight thin))
                                 ("Helvetica Neue Thin"          (:family "Helvetica Neue" :weight ultra-light))
                                 ("Bodini 72"                    (:family "Bodini 72" :weight normal))
                                 ("American Typewriter Light"    (:family "American Typewriter" :weight light))
                                 ("American Typewriter Regular"  (:family "American Typewriter" :weight normal))
                                 ("Futura"                       (:family "Futura" :weight normal))
                                 ("Gill Sans Regular"            (:family "Gill Sans" :weight normal))
                                 ("Gill Sans Light"              (:family "Gill Sans" :weight light))
                                 ("Avenir Next Ultralight"       (:family "Avenir Next" :weight thin))
                                 ("Avenir Next Regular"          (:family "Avenir Next" :weight normal))))
         (modeline-fonts (append default-mono-fonts variable-pitch-fonts))

         (selected-fonts (--map (assoc
                                 (completing-read (format "Select [nil to skip]:" (car it)) (-map (lambda (that) (car that)) it))
                                 it)
                          (list default-mono-fonts
                                variable-pitch-fonts
                                modeline-fonts))))

       (when (car selected-fonts) (setq doom-font (apply 'font-spec (cadr (car selected-fonts)))))
       (when (cadr selected-fonts) (setq doom-variable-pitch-font (apply 'font-spec (cadr (cadr selected-fonts)))))
       (when (caddr selected-fonts)
        (let* ((spec (cadr (caddr selected-fonts)))
               (font (plist-get spec :family))
               (weight (plist-get spec :weight)))
           (set-face-attribute 'mode-line nil :family font :weight weight)
           (set-face-attribute 'mode-line-inactive nil :family font :weight weight)))
      (doom/reload-font)))
