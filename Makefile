reload:
	stow --target=$$HOME --adopt --restow . && cat ~/.crontab | crontab
