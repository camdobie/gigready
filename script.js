console.log("javascript file loaded");

const setlistGrid = document.querySelector('.setlist-grid');
const songList = document.querySelector('.song-list');
const songGrid = document.querySelector('.song-grid');
const lyricsDisplay = document.querySelector('.lyrics-display');
const lyricsContent = document.querySelector('.lyrics-content');
const backButton = document.getElementById('backButton');
const songBackButton = document.getElementById('songBackButton');
const addSongButton = document.getElementById('addSongButton');
const songModal = document.getElementById('songModal');
const closeButton = document.querySelector('.close');
const saveSongButton = document.getElementById('saveSongButton');
const songNameInput = document.getElementById('songNameInput');
const songLyricsInput = document.getElementById('songLyricsInput');
const deleteSongButton = document.getElementById('deleteSongButton');
const viewAllSongsButton = document.getElementById('viewAllSongsButton');
const allSongsList = document.querySelector('.all-songs-list');
const allSongGrid = document.querySelector('.all-song-grid');
const allSongsBackButton = document.getElementById('allSongsBackButton');
const addAllSongButton = document.getElementById('addAllSongButton');
const setlistDropdown = document.getElementById('setlistDropdown');
const setlistSelect = document.getElementById('setlistSelect');

let currentSetlist = null;
let viewAll = false;

// ... (rest of the code, including displaySongs, displayLyrics, saveSong, deleteSong) ...

viewAllSongsButton.addEventListener('click', () => {
    setlistGrid.style.display = 'none';
    allSongsList.style.display = 'block';
    displayAllSongs();
});

function displayAllSongs() {
    allSongGrid.innerHTML = '';
    const songs = JSON.parse(localStorage.getItem('songs')) || {};
    const allSongs = {};
    Object.keys(songs).forEach(setlist => {
        Object.keys(songs[setlist]).forEach(song => {
            allSongs[song] = setlist;
        });
    });
    Object.keys(allSongs).forEach(song => {
        const songItem = document.createElement('div');
        songItem.classList.add('song-item');
        songItem.textContent = song;
        songItem.dataset.song = song;
        songItem.dataset.setlist = allSongs[song];
        allSongGrid.appendChild(songItem);
    });
}

allSongGrid.addEventListener('click', (event) => {
    if (event.target.classList.contains('song-item')) {
        const songName = event.target.dataset.song;
        currentSetlist = event.target.dataset.setlist;
        displayLyrics(songName);
    }
});

addAllSongButton.addEventListener('click', () => {
    viewAll = true;
    setlistDropdown.style.display = 'block';
    songModal.style.display = 'block';
});

allSongsBackButton.addEventListener('click', () => {
    allSongsList.style.display = 'none';
    setlistGrid.style.display = 'grid';
    viewAll = false;
});

saveSongButton.addEventListener('click', () => {
    const songName = songNameInput.value;
    const lyricsAndChords = songLyricsInput.value;
    const setlistName = viewAll ? setlistSelect.value : currentSetlist;
    saveSong(songName, lyricsAndChords, setlistName);
    songModal.style.display = 'none';
    if (viewAll) {
        displayAllSongs();
    } else {
        displaySongs(currentSetlist);
    }
    setlistDropdown.style.display = 'none';
    viewAll = false;
});
