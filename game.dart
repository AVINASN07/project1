const canvas = document.getElementById('gameCanvas');
const ctx = canvas.getContext('2d');
canvas.width = window.innerWidth;
canvas.height = window.innerHeight;

// Game variables
let gravity = 0.8;
let friction = 0.9;
let isJumping = false;
let isFalling = false;
let mario = {
    x: 50,
    y: canvas.height - 150,
    width: 50,
    height: 70,
    speedX: 0,
    speedY: 0,
    speed: 5,
    color: 'red',
    jumpStrength: -15,
    collectedCoins: 0,
};

let ground = canvas.height - 50;
let platforms = [
    { x: 100, y: canvas.height - 150, width: 300, height: 20 },
    { x: 500, y: canvas.height - 250, width: 200, height: 20 },
    { x: 900, y: canvas.height - 350, width: 250, height: 20 },
];
let coins = [
    { x: 150, y: canvas.height - 190, radius: 10 },
    { x: 550, y: canvas.height - 290, radius: 10 },
    { x: 950, y: canvas.height - 390, radius: 10 },
];

// Keyboard controls
let keys = {
    right: false,
    left: false,
    up: false,
};

// Event listeners for keys
window.addEventListener('keydown', (e) => {
    if (e.key === 'ArrowRight') keys.right = true;
    if (e.key === 'ArrowLeft') keys.left = true;
    if (e.key === 'ArrowUp' && !isJumping && !isFalling) {
        keys.up = true;
        mario.speedY = mario.jumpStrength;
        isJumping = true;
    }
});

window.addEventListener('keyup', (e) => {
    if (e.key === 'ArrowRight') keys.right = false;
    if (e.key === 'ArrowLeft') keys.left = false;
    if (e.key === 'ArrowUp') keys.up = false;
});

// Collision detection
function checkCollision(rect, obj) {
    return rect.x < obj.x + obj.width &&
        rect.x + rect.width > obj.x &&
        rect.y < obj.y + obj.height &&
        rect.y + rect.height > obj.y;
}

// Mario physics & movement
function update() {
    // Left and right movement
    if (keys.right) mario.speedX = mario.speed;
    if (keys.left) mario.speedX = -mario.speed;

    // Apply gravity
    if (isJumping || isFalling) {
        mario.speedY += gravity;
    }

    // Apply friction
    mario.speedX *= friction;

    // Update Mario's position
    mario.x += mario.speedX;
    mario.y += mario.speedY;

    // Boundaries
    if (mario.x < 0) mario.x = 0;
    if (mario.x + mario.width > canvas.width) mario.x = canvas.width - mario.width;
    if (mario.y + mario.height > ground) {
        mario.y = ground - mario.height;
        isJumping = false;
        isFalling = false;
        mario.speedY = 0;
    }

    // Fall through ground (simple fall detection)
    if (mario.y + mario.height < ground) {
        isFalling = true;
    }

    // Platform collision detection
    for (let i = 0; i < platforms.length; i++) {
        let platform = platforms[i];
        if (checkCollision(mario, platform)) {
            mario.y = platform.y - mario.height;
            mario.speedY = 0;
            isJumping = false;
            isFalling = false;
        }
    }

    // Collect coins
    for (let i = 0; i < coins.length; i++) {
        let coin = coins[i];
        let coinRect = { x: coin.x - coin.radius, y: coin.y - coin.radius, width: coin.radius * 2, height: coin.radius * 2 };
        if (checkCollision(mario, coinRect)) {
            coins.splice(i, 1);
            mario.collectedCoins++;
            break;
        }
    }

    // Clear the canvas
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    // Draw platforms
    ctx.fillStyle = 'green';
    platforms.forEach(platform => ctx.fillRect(platform.x, platform.y, platform.width, platform.height));

    // Draw coins
    ctx.fillStyle = 'yellow';
    coins.forEach(coin => ctx.beginPath() && ctx.arc(coin.x, coin.y, coin.radius, 0, Math.PI * 2) && ctx.fill());

    // Draw Mario
    ctx.fillStyle = mario.color;
    ctx.fillRect(mario.x, mario.y, mario.width, mario.height);

    // Draw collected coins count
    ctx.fillStyle = 'white';
    ctx.font = '20px Arial';
    ctx.fillText('Coins: ' + mario.collectedCoins, 10, 30);
}

function gameLoop() {
    update();
    requestAnimationFrame(gameLoop);
}

gameLoop();
