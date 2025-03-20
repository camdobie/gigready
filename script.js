const setlistGrid = document.querySelector('.setlist-grid');
const songList = document.querySelector('.song-list');
const songGrid = document.querySelector('.song-grid');
const lyricsDisplay = document.querySelector('.lyrics-display');
const lyricsContent = document.querySelector('.lyrics-content');
const backButton = document.getElementById('backButton');
const songBackButton = document.getElementById('songBackButton');

setlistGrid.addEventListener('click', (event) => {
    if (event.target.classList.contains('setlist-item')) {
        const setlistName = event.target.dataset.setlist;
        displaySongs(setlistName);
    }
});

function displaySongs(setlistName) {
    setlistGrid.style.display = 'none';
    songList.style.display = 'block';
    songGrid.innerHTML = ''; // Clear previous songs

    // Example song data (replace with your actual data)
    const songs = {
        'Set 1': ['Song 1', 'Song 2', 'Song 3'],
        'Set 2': ['Song A', 'Song B', 'Song C'],
        'Set 3': ['Song X', 'Song Y', 'Song Z']
    };

    songs[setlistName].forEach(song => {
        const songItem = document.createElement('div');
        songItem.classList.add('song-item');
        songItem.textContent = song;
        songItem.dataset.song = song;
        songGrid.appendChild(songItem);
    });
}

songGrid.addEventListener('click', (event) => {
    if (event.target.classList.contains('song-item')) {
        const songName = event.target.dataset.song;
        displayLyrics(songName);
    }
});

function displayLyrics(songName) {
    songList.style.display = 'none';
    lyricsDisplay.style.display = 'block';
    lyricsContent.innerHTML = ''; // Clear previous lyrics

    // Example lyrics data (replace with your actual data)
    const lyrics = {
        'Song 1': 'Lyrics for Song 1...',
        'Song 2': 'Lyrics for Song 2...',
        'Song 3': 'Lyrics for Song 3...',
        'Song A': 'Lyrics for Song A...',
        'Song B': 'Lyrics for Song B...',
        'Song C': 'Lyrics for Song C...',
        'Song X': 'Lyrics for Song X...',
        'Song Y': 'Lyrics for Song Y...',
        'Song Z': 'Lyrics for Song Z...',

    };

    lyricsContent.textContent = lyrics[songName];
}

backButton.addEventListener('click', () => {
    songList.style.display = 'none';
    setlistGrid.style.display = 'grid';
});

songBackButton.addEventListener('click', () => {
    lyricsDisplay.style.display = 'none';
    songList.style.display = 'block';
});
