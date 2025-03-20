// ... (previous JavaScript) ...

saveSongButton.addEventListener('click', () => {
    const songName = songNameInput.value;
    const lyricsAndChords = songLyricsInput.value;
    const setlistName = document.querySelector('.song-list h1').textContent.replace('Songs', '').trim(); // Get the current setlist name
    saveSong(songName, lyricsAndChords, setlistName); // Pass setlistName
    songModal.style.display = 'none';
});

function saveSong(songName, lyricsAndChords, setlistName) {
    let songs = JSON.parse(localStorage.getItem('songs')) || {};
    if (!songs[setlistName]) {
        songs[setlistName] = {};
    }
    songs[setlistName][songName] = lyricsAndChords;
    localStorage.setItem('songs', JSON.stringify(songs));
    displaySongs(setlistName); // Refresh the song list
}

function displaySongs(setlistName) {
    setlistGrid.style.display = 'none';
    songList.style.display = 'block';
    songGrid.innerHTML = '';
    document.querySelector('.song-list h1').textContent = `Songs - ${setlistName}`; // Update heading
    const songs = JSON.parse(localStorage.getItem('songs')) || {};
    if (songs[setlistName]) {
        Object.keys(songs[setlistName]).forEach(song => {
            const songItem = document.createElement('div');
            songItem.classList.add('song-item');
            songItem.textContent = song;
            songItem.dataset.song = song;
            songGrid.appendChild(songItem);
        });
    }
}

// ... (rest of the JavaScript) ...
