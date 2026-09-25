# Social card

`content/img/og.png` (1200×630) is a screenshot of `index.html` in this folder.

To regenerate after editing it:

```sh
cp ../../content/img/deeplife-icon-512.png icon.png
python3 -m http.server 4100 &
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless --disable-gpu --hide-scrollbars --force-device-scale-factor=1 \
  --window-size=1200,630 --virtual-time-budget=3000 \
  --screenshot=../../content/img/og.png http://localhost:4100/
kill %1; rm icon.png
```
