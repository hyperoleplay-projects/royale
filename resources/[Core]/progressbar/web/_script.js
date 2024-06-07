var $progressBar = null;

$(document).ready(function() {
    $("#hud").fadeIn();

    window.addEventListener("message", function(event) {
        let data = event.data;

        switch (data.action) {
            case "createProgressBar":
                createProgressBar(data["time"],data["text"]);

                break;
            case "removeProgressBar":
                removeCurrentProgressBar();

                break;
            default:
                break;
        }
    });
});

function createProgressBar($time,$text) {
    $("#progress-bar").html(`
        <div class="info">
            <div class="percent" id="progress-percent"></div>
            <div class="text">${$text.toUpperCase()}</div>
        </div>
        <div class="bar"><div id="progress-bar-bar"  style="animation: progress ${$time}s forwards;" class="fill"></div></div>
    `);

    setTimeout(() => {
        removeCurrentProgressBar();
    }, ($time + 0.2) * 1000);

    $progressBarPercent = 0;

    $progressBar = setInterval(() => {
        if ($progressBarPercent >= 100) {
            return
        }

        $progressBarPercent = $progressBarPercent + 1;

        $("#progress-percent").html($progressBarPercent+"%");
    }, $time/100 * 1000);
}

function removeCurrentProgressBar() {
    clearInterval($progressBar);
    $progressBarPercent = 0;
    $("#progress-bar").empty();
}
