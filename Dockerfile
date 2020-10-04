FROM archlinux

RUN pacman -Sy --noconfirm nodejs npm curl

RUN npm install pm2 -g

RUN curl -L https://github.com/luvit/lit/raw/master/get-lit.sh | sh

RUN mv ./luvit /bin

WORKDIR /code

COPY . .

CMD ["pm2-runtime", "process.yml"]