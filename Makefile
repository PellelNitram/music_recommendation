include .env
export

IA_BASE_URL = https://archive.org/download
LB_FTP_BASE_URL = https://ftp.musicbrainz.org/pub/musicbrainz/listenbrainz/incremental

.PHONY: up down restart logs status download-songs download-listens create-playlist

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

define download-and-extract
	@mkdir -p $(LB_DATA_FOLDER)/$(1)
	@echo "Downloading listenbrainz-listens-dump-$(1)-$(2)-incremental.tar.zst..."
	@curl -L -o "$(LB_DATA_FOLDER)/listenbrainz-listens-dump-$(1)-$(2)-incremental.tar.zst" \
		"$(LB_FTP_BASE_URL)/listenbrainz-dump-$(1)-$(2)-incremental/listenbrainz-listens-dump-$(1)-$(2)-incremental.tar.zst"
	@echo "Extracting to $(LB_DATA_FOLDER)/$(1)/..."
	@zstd -d "$(LB_DATA_FOLDER)/listenbrainz-listens-dump-$(1)-$(2)-incremental.tar.zst" --stdout | \
		tar xf - -C "$(LB_DATA_FOLDER)/$(1)/" --strip-components=1
	@rm "$(LB_DATA_FOLDER)/listenbrainz-listens-dump-$(1)-$(2)-incremental.tar.zst"
endef

download-listens:
	@echo "Downloading 3 days of incremental ListenBrainz listen data..."
	$(call download-and-extract,2500,20260421-000004)
	$(call download-and-extract,2501,20260422-000004)
	$(call download-and-extract,2502,20260423-000004)
	@echo "Done! Extracted listen data to $(LB_DATA_FOLDER)/{2500,2501,2502}/"

create-playlist:
	@./scripts/create-playlist.sh
