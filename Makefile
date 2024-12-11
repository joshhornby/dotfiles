reload:
	stow --target=$$HOME --restow . && cat ~/.crontab | crontab -
