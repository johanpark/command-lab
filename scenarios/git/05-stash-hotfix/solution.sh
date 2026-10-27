cd ~/shop
git stash -q
git switch -q main
sed -i 's/TAX_RATE = 0.01/TAX_RATE = 0.1/' price.js
git commit -qam "세율 버그 수정"
git switch -q feature/coupon
git stash pop -q
