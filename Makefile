include .env
export

IA_BASE_URL = https://archive.org/download

.PHONY: up down restart logs status download-songs create-playlist

up:
	@mkdir -p $(ND_DATA_FOLDER) $(ND_MUSIC_FOLDER)
	docker compose up -d

down:
	docker compose down

restart:
	docker compose restart

logs:
	docker compose logs -f

status:
	docker compose ps

download-songs:
	@mkdir -p $(ND_MUSIC_FOLDER)/ProleteR $(ND_MUSIC_FOLDER)/RidingAlone
	@echo "Downloading free Creative Commons music from Internet Archive..."
	@curl -L -o "$(ND_MUSIC_FOLDER)/ProleteR/April_Showers.mp3" \
		"$(IA_BASE_URL)/DWK123/ProleteR_-_01_-_April_Showers.mp3"
	@curl -L -o "$(ND_MUSIC_FOLDER)/ProleteR/Downtown_Irony.mp3" \
		"$(IA_BASE_URL)/DWK123/ProleteR_-_02_-_Downtown_Irony.mp3"
	@curl -L -o "$(ND_MUSIC_FOLDER)/ProleteR/Soul_Key.mp3" \
		"$(IA_BASE_URL)/DWK123/ProleteR_-_03_-_Soul_Key.mp3"
	@curl -L -o "$(ND_MUSIC_FOLDER)/ProleteR/Muhammad_Ali.mp3" \
		"$(IA_BASE_URL)/DWK123/ProleteR_-_07_-_Muhammad_Ali.mp3"
	@curl -L -o "$(ND_MUSIC_FOLDER)/RidingAlone/Lullaby.mp3" \
		"$(IA_BASE_URL)/badpanda018/01RidingAloneForThousandsOfMiles-Lullaby.mp3"
	@curl -L -o "$(ND_MUSIC_FOLDER)/RidingAlone/Satellite.mp3" \
		"$(IA_BASE_URL)/badpanda018/05RidingAloneForThousandsOfMiles-Satellite.mp3"
	@curl -L -o "$(ND_MUSIC_FOLDER)/RidingAlone/Love_Song.mp3" \
		"$(IA_BASE_URL)/badpanda018/04RidingAloneForThousandsOfMiles-LoveSong.mp3"
	@echo "Done! Downloaded 7 songs to $(ND_MUSIC_FOLDER)"

create-playlist:
	@./scripts/create-playlist.sh
