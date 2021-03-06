;; screengrab-soma --- Take screengrabs of soma renders with each style available.

;;; Commentary:

;;  With each style start a

;;; Code:

(defun screenshots-list ()
  (mapcar
   (lambda (file)
     (s-split "+"
              (s-replace ".png" ""
                         (s-replace "/Users/jason/.doom.d/soma-screenshots/" "" file))))
   (f-entries "/Users/jason/.doom.d/soma-screenshots/"
              (lambda (file) (s-ends-with? ".png" file)))))

(setq-local css-styles-list
            '(("github-dark"  "/Users/jason/workspace/soma/styles/github-dark.css")
              ("github-light"  "/Users/jason/workspace/soma/styles/github-light.css")
              ("ink"  "/Users/jason/workspace/soma/styles/ink.css")
              ("chillwave"  "/Users/jason/workspace/soma/styles/lopped-off-dark-chillwave.css")
              ("obsidian"  "/Users/jason/workspace/soma/styles/lopped-off-dark-obsidian.css")
              ("ultraviolet"  "/Users/jason/workspace/soma/styles/lopped-off-dark-ultraviolet.css")
              ("dark" "/Users/jason/workspace/soma/styles/lopped-off-dark.css")
              ("light" "/Users/jason/workspace/soma/styles/lopped-off.css")
              ("smoooth"  "/Users/jason/workspace/soma/styles/smoooth.css")))

(setq-local css-styles-plist
            '((:style "github-dark"  :path "/Users/jason/workspace/soma/styles/github-dark.css")
              (:style "github-light" :path "/Users/jason/workspace/soma/styles/github-light.css")
              (:style "ink"          :path "/Users/jason/workspace/soma/styles/ink.css")
              (:style "chillwave"    :path "/Users/jason/workspace/soma/styles/lopped-off-dark-chillwave.css")
              (:style "obsidian"     :path "/Users/jason/workspace/soma/styles/lopped-off-dark-obsidian.css")
              (:style "ultraviolet"  :path "/Users/jason/workspace/soma/styles/lopped-off-dark-ultraviolet.css")
              (:style "dark"         :path "/Users/jason/workspace/soma/styles/lopped-off-dark.css")
              (:style "light"        :path "/Users/jason/workspace/soma/styles/lopped-off.css")
              (:style "smoooth"      :path "/Users/jason/workspace/soma/styles/smoooth.css")))

(defun screengrab-master-list ()
  "Master list of soma styles / syntax highlights"
  (first
   (--map
    (-map (lambda (highlight)
            (let ((style (car it)))
              `(,style ,highlight)
              ))
          markdown-soma-highlightjs-theme-list)
    css-styles-list)))

(defun screengrab-soma-missing ()
  "Compare list of screenhots vs required."
  (--map (s-split " " it)
         (-difference
          (-sort 'string> (--map (s-join " " it) (screengrab-master-list)))
          (-sort 'string> (--map (s-join " " it) (screenshots-list))))))
(screengrab-soma-missing)

(defun screengrab-soma ()
  "Generate screen captures of soma themes"
  (let ((markdown-soma-host-port "0")
        (markdown-soma-host-address "localhost")

        (screencapture-mac-default-commandline
         (format "screencapture -l %s -x -o"
                 (screencapture-mac--windowid-helper)))

        (screencapture-mac-default-file-location (expand-file-name"~/Desktop"))
        (screencapture-mac-default-file-keyword "soma-screencapture")
        (text (f-read-text "~/workspace/soma/code-samples.md")))

    (mapc
     (lambda (style)
       (let ((type (nth 0 style))
             (markdown-soma-custom-css (expand-file-name (nth 1 style))))

         (mapc ; loop over highlight styles
          (lambda (highlight-style)
            (let ((screencapture-mac-default-file-keyword
                   (format "soma-%s-%s" type highlight-style))
                  (markdown-soma-highlight-theme highlight-style))

              (progn

                ;; - - 8< - - - - - -
                ;; run soma command
                (markdown-soma--run)
                ;; render string
                (markdown-soma-render text)
                ;; Wait a moment...
                (y-or-n-p-with-timeout "Waiting for reload...?" 3 t)
                ;; Click...
                (screencapture-mac)
                ;; kill soma process + buffer
                (markdown-soma--kill)
                (shell-command "pkill soma")
                (y-or-n-p-with-timeout "Waiting for process die...?" 1 t)
                ;; Tell Chrome to kill a tab from the top window.
                )

              ))
          markdown-soma-highlightjs-theme-list)))

     css-styles-list)))

(defun screengrab-soma-cleanup ()
  "Redo screen captures of borked caps.
The original run didn't wait long enough for
the preview to load before capture and close."

  (let ((markdown-soma-host-port "0")
        (markdown-soma-host-address "localhost")

        (screencapture-mac-default-commandline
         (format "screencapture -l %s -x -o"
                 (screencapture-mac--windowid-helper)))

        (screencapture-mac-default-file-location (expand-file-name"~/Desktop"))
        (screencapture-mac-default-file-keyword "soma-screencapture")
        (text (f-read-text "~/workspace/soma/code-samples.md")))

    (mapc
     (lambda (style)
       (let ((markdown-soma-custom-css (expand-file-name (nth 1 style)))
             (screencapture-mac-default-file-keyword (format "soma-[%s]-[%s]-" (car style) (nth 2 style)))
             (markdown-soma-highlight-theme (nth 2 style)))

         ;; - - 8< - - - - - -
         ;; run soma command
         (markdown-soma--run)
         ;; render string
         (markdown-soma-render text)

         ;; Wait a moment...
         (y-or-n-p-with-timeout "Waiting for reload...?"  t)
         ;; Click...
         (screencapture-mac)
         ;; kill soma process + buffer
         (markdown-soma--kill)
         (shell-command "pkill soma")
         (y-or-n-p-with-timeout "Waiting for process die...?" 1 t)))

     '(("chillwave"     "~/workspace/soma/styles/lopped-off-dark-chillwave.css"   "nnfx-dark")
       ("ultraviolet"     "~/workspace/soma/styles/lopped-off-dark-ultraviolet.css" "pojoaque")
       ("ultraviolet"     "~/workspace/soma/styles/lopped-off-dark-ultraviolet.css" "rebecca")
       ("ultraviolet"     "~/workspace/soma/styles/lopped-off-dark-ultraviolet.css" "stackoverflow-light")
       ("github-dark"     "~/workspace/soma/styles/github-dark.css"                 "androidstudio")
       ("github-dark"     "~/workspace/soma/styles/github-dark.css"                 "atelier-dune.light")
       ("github-dark"     "~/workspace/soma/styles/github-dark.css"                 "atelier-dune")
       ("github-dark"     "~/workspace/soma/styles/github-dark.css"                 "atelier-heath-light")
       ("github-dark"     "~/workspace/soma/styles/github-dark.css"                 "atelier-savanna-dark")
       ("github-dark"     "~/workspace/soma/styles/github-dark.css"                 "atelier-sulphurpool.light")
       ("github-dark"     "~/workspace/soma/styles/github-dark.css"                 "black-metal-nile")
       ("github-dark"     "~/workspace/soma/styles/github-dark.css"                 "classic-dark")
       ("github-dark"     "~/workspace/soma/styles/github-dark.css"                 "darkula")
       ("github-dark"     "~/workspace/soma/styles/github-dark.css"                 "equilibrium-gray-dark")
       ("github-dark"     "~/workspace/soma/styles/github-dark.css"                 "github-dark")
       ("github-dark"     "~/workspace/soma/styles/github-dark.css"                 "gruvbox-dark-medium")
       ("github-dark"     "~/workspace/soma/styles/github-dark.css"                 "hopscotch")
       ("github-dark"     "~/workspace/soma/styles/github-dark.css"                 "isbl-editor-light")
       ("github-dark"     "~/workspace/soma/styles/github-dark.css"                 "material-darker")
       ("github-dark"     "~/workspace/soma/styles/github-dark.css"                 "nnfx-dark")
       ("github-dark"     "~/workspace/soma/styles/github-dark.css"                 "paraiso-dark")
       ("github-dark"     "~/workspace/soma/styles/github-dark.css"                 "qtcreator-light")
       ("github-dark"     "~/workspace/soma/styles/github-dark.css"                 "school-book.png")
       ("github-dark"     "~/workspace/soma/styles/github-dark.css"                 "solarized_light")
       ("github-dark"     "~/workspace/soma/styles/github-dark.css"                 "tokyo-night-light")
       ("github-dark"     "~/workspace/soma/styles/github-dark.css"                 "windows-95-light")
       ("github-light"    "~/workspace/soma/styles/github-light.css"                "agate")
       ("github-light"    "~/workspace/soma/styles/github-light.css"                "atelier-dune-dark")
       ("github-light"    "~/workspace/soma/styles/github-light.css"                "atelier-forest.light")
       ("github-light"    "~/workspace/soma/styles/github-light.css"                "atelier-plateau.dark")
       ("github-light"    "~/workspace/soma/styles/github-light.css"                "atelier-sulphurpool")
       ("github-light"    "~/workspace/soma/styles/github-light.css"                "black-metal-marduk")
       ("github-light"    "~/workspace/soma/styles/github-light.css"                "circus")
       ("github-light"    "~/workspace/soma/styles/github-light.css"                "darktooth")
       ("github-light"    "~/workspace/soma/styles/github-light.css"                "equilibrium-gray-dark")
       ("github-light"    "~/workspace/soma/styles/github-light.css"                "github-dark")
       ("github-light"    "~/workspace/soma/styles/github-light.css"                "gruvbox-dark-medium")
       ("github-light"    "~/workspace/soma/styles/github-light.css"                "horizon-dark")
       ("github-light"    "~/workspace/soma/styles/github-light.css"                "isotope")
       ("github-light"    "~/workspace/soma/styles/github-light.css"                "magula")
       ("github-light"    "~/workspace/soma/styles/github-light.css"                "marrakesh")
       ("github-light"    "~/workspace/soma/styles/github-light.css"                "material-darker")
       ("github-light"    "~/workspace/soma/styles/github-light.css"                "material-lighter")
       ("github-light"    "~/workspace/soma/styles/github-light.css"                "material-palenight")
       ("github-light"    "~/workspace/soma/styles/github-light.css"                "nord")
       ("github-light"    "~/workspace/soma/styles/github-light.css"                "paraiso")
       ("github-light"    "~/workspace/soma/styles/github-light.css"                "qtcreator_light")
       ("github-light"    "~/workspace/soma/styles/github-light.css"                "school_book.png")
       ("github-light"    "~/workspace/soma/styles/github-light.css"                "srcery")
       ("github-light"    "~/workspace/soma/styles/github-light.css"                "tomorrow-night-bright")
       ("github-light"    "~/workspace/soma/styles/github-light.css"                "windows-high-contrast-light")
       ("ink"             "~/workspace/soma/styles/ink.css"                         "androidstudio")
       ("ink"             "~/workspace/soma/styles/ink.css"                         "atelier-dune.dark")
       ("ink"             "~/workspace/soma/styles/ink.css"                         "atelier-dune")
       ("ink"             "~/workspace/soma/styles/ink.css"                         "atelier-heath")
       ("ink"             "~/workspace/soma/styles/ink.css"                         "atelier-savanna-light")
       ("ink"             "~/workspace/soma/styles/ink.css"                         "atelier-savanna")
       ("ink"             "~/workspace/soma/styles/ink.css"                         "atom-one-dark-reasonable")
       ("ink"             "~/workspace/soma/styles/ink.css"                         "black-metal")
       ("ink"             "~/workspace/soma/styles/ink.css"                         "brewer")
       ("ink"             "~/workspace/soma/styles/ink.css"                         "codeschool")
       ("ink"             "~/workspace/soma/styles/ink.css"                         "default-light")
       ("ink"             "~/workspace/soma/styles/ink.css"                         "dracula")
       ("ink"             "~/workspace/soma/styles/ink.css"                         "equilibrium-gray-light")
       ("ink"             "~/workspace/soma/styles/ink.css"                         "equilibrium-light")
       ("ink"             "~/workspace/soma/styles/ink.css"                         "espresso")
       ("ink"             "~/workspace/soma/styles/ink.css"                         "eva-dim")
       ("ink"             "~/workspace/soma/styles/ink.css"                         "eva")
       ("ink"             "~/workspace/soma/styles/ink.css"                         "flat")
       ("ink"             "~/workspace/soma/styles/ink.css"                         "gml")
       ("ink"             "~/workspace/soma/styles/ink.css"                         "google-dark")
       ("ink"             "~/workspace/soma/styles/ink.css"                         "gruvbox-light-hard")
       ("ink"             "~/workspace/soma/styles/ink.css"                         "gruvbox-light-medium")
       ("ink"             "~/workspace/soma/styles/ink.css"                         "hybrid")
       ("ink"             "~/workspace/soma/styles/ink.css"                         "ia-dark")
       ("ink"             "~/workspace/soma/styles/ink.css"                         "kimbie.light")
       ("ink"             "~/workspace/soma/styles/ink.css"                         "mexico-light")
       ("ink"             "~/workspace/soma/styles/ink.css"                         "mocha")
       ("ink"             "~/workspace/soma/styles/ink.css"                         "one-light")
       ("ink"             "~/workspace/soma/styles/ink.css"                         "onedark")
       ("ink"             "~/workspace/soma/styles/ink.css"                         "pojoaque.jpg")
       ("ink"             "~/workspace/soma/styles/ink.css"                         "pojoaque")
       ("ink"             "~/workspace/soma/styles/ink.css"                         "ros-pine")
       ("ink"             "~/workspace/soma/styles/ink.css"                         "snazzy")
       ("ink"             "~/workspace/soma/styles/ink.css"                         "solar-flare-light")
       ("ink"             "~/workspace/soma/styles/ink.css"                         "solar-flare")
       ("ink"             "~/workspace/soma/styles/ink.css"                         "synth-midnight-terminal-light")
       ("ink"             "~/workspace/soma/styles/ink.css"                         "vs2015")
       ("ink"             "~/workspace/soma/styles/ink.css"                         "vulcan")
       ("lopped-off-dark" "~/workspace/soma/styles/lopped-off-dark.css"             "atelier-lakeside-dark")
       ("lopped-off-dark" "~/workspace/soma/styles/lopped-off-dark.css"             "paraiso.light")
       ("lopped-off"      "~/workspace/soma/styles/lopped-off.css"                  "atelier-heath.dark")
       ("lopped-off"      "~/workspace/soma/styles/lopped-off.css"                  "qtcreator_light")
       ("lopped-off"      "~/workspace/soma/styles/lopped-off.css"                  "school_book.png")
       ("lopped-off"      "~/workspace/soma/styles/lopped-off.css"                  "srcery")
       ("lopped-off"      "~/workspace/soma/styles/lopped-off.css"                  "tomorrow-night-bright")
       ("lopped-off"      "~/workspace/soma/styles/lopped-off.css"                  "windows-high-contrast-light")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "3024")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "apprentice")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "atelier-cave.dark")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "atelier-cave.light")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "atelier-cave")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "atelier-forest.dark")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "atelier-forest")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "atelier-plateau")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "atelier-sulphurpool-light")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "atelier-sulphurpool")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "black-metal-marduk")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "chalk")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "circus")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "darktooth")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "darkula")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "equilibrium-gray-dark")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "github-dark")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "github-gist")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "gruvbox-dark-pale")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "gruvbox-dark-soft")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "harmonic16-light")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "horizon-dark")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "horizon-light")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "kimber")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "material-palenight")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "material-vivid")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "nova")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "paraiso.dark")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "paraiso.light")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "railscasts")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "rainbow")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "shades-of-purple")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "shapeshifter")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "summercamp")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "summerfruit-dark")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "tomorrow")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "twilight")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "windows-10-light")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "windows-10")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "windows-nt")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "woodland")
       ("smoooth"         "~/workspace/soma/styles/smoooth.css"                     "xcode-dusk")))))

;; (screengrab-soma)

(provide 'screengrab-soma)

;;; screengrab-soma.el ends here
