#!/bin/bash

docker compose up --build &
sleep 5
xdg-open http://localhost:3000

