document.addEventListener("DOMContentLoaded", function () {
  const cuttingMenu = document.getElementById("cuttingMenu");
  const juiceMenu = document.getElementById("juiceMenu");

  const closeCuttingBtn = document.getElementById("closeCuttingBtn");
  const closeJuiceBtn = document.getElementById("closeJuiceBtn");

  const cuttingOptions = document.getElementById("cutting-options");
  const juiceOptions = document.getElementById("juice-options");

  // Hide menus on load
  cuttingMenu.style.display = "none";
  juiceMenu.style.display = "none";

  /* ========== IMAGES for Cutting ========== */
  const cuttingImages = {
    lemon: "lemon.png",
    orange: "orange.png",
    pineapple: "pineapple.png"
  };

  /* ========== IMAGES for Juices ========== */
  const juiceImages = {
    lemonjuice: "lemonjuice.png",
    orangejuice: "orangejuice.png",
    pineapplejuice: "pineapplejuice.png"
  };

  /* ========== Fruit to Slice Mapping ========== */
  // Key = the name of the whole fruit item in your server
  // 'sliceName' = the item name for the slices that will be produced
  const cuttingData = {
    lemon: { sliceName: "lemonslice" },
    orange: { sliceName: "orangeslice" },
    pineapple: { sliceName: "pineappleslice" }
  };

  /* ========== Juice Recipe Mapping ========== */
  // Key = final juice item
  // 'requiredItem' = the slice item needed
  const juiceData = {
    lemonjuice: { requiredItem: "lemonslice" },
    orangejuice: { requiredItem: "orangeslice" },
    pineapplejuice: { requiredItem: "pineappleslice" }
  };

  /* ========== Listen for NUI messages from client.lua ========== */
  window.addEventListener("message", function (event) {
    if (event.data.action === "openCuttingMenu") {
      openCuttingMenu();
    }
    if (event.data.action === "closeCuttingMenu") {
      cuttingMenu.style.display = "none";
    }
    if (event.data.action === "openJuiceMenu") {
      openJuiceMenu();
    }
    if (event.data.action === "closeJuiceMenu") {
      juiceMenu.style.display = "none";
    }
  });

  /* ========== BUILD CUTTING MENU ========== */
  function openCuttingMenu() {
    cuttingMenu.style.display = "block";
    cuttingOptions.innerHTML = "";

    // For each fruit in cuttingData, build a row
    Object.keys(cuttingData).forEach((fruit) => {
      let fruitInfo = cuttingData[fruit];
      let imageUrl = `./images/${cuttingImages[fruit]}`;

      let itemRow = document.createElement("div");
      itemRow.classList.add("cutting-item");

      itemRow.innerHTML = `
        <img src="${imageUrl}" alt="${fruit}" class="cutting-img">
        <div class="cutting-details">
          <span class="cutting-name">${fruit.toUpperCase()}</span>
          <div class="ingredients">Yields: 1x ${fruitInfo.sliceName}</div>
        </div>
        <button onclick="cutFruit('${fruit}','${fruitInfo.sliceName}')">🔪 Cut</button>
      `;

      cuttingOptions.appendChild(itemRow);
    });
  }

  /* ========== BUILD JUICE MENU ========== */
  function openJuiceMenu() {
    juiceMenu.style.display = "block";
    juiceOptions.innerHTML = "";

    // For each juice in juiceData, build a row
    Object.keys(juiceData).forEach((juiceName) => {
      let juiceInfo = juiceData[juiceName];
      let imageUrl = `./images/${juiceImages[juiceName]}`;

      let itemRow = document.createElement("div");
      itemRow.classList.add("juice-item");

      itemRow.innerHTML = `
        <img src="${imageUrl}" alt="${juiceName}" class="juice-img">
        <div class="juice-details">
          <span class="juice-name">${juiceName.toUpperCase()}</span>
          <div class="ingredients">Requires: 1x ${juiceInfo.requiredItem}</div>
        </div>
        <button onclick="prepareJuice('${juiceName}','${juiceInfo.requiredItem}')">🍹 Prepare</button>
      `;

      juiceOptions.appendChild(itemRow);
    });
  }

  /* ========== CLOSE BUTTONS ========== */
  closeCuttingBtn.addEventListener("click", function () {
    fetch(`https://${GetParentResourceName()}/closeCuttingMenu`, { method: "POST" });
  });

  closeJuiceBtn.addEventListener("click", function () {
    fetch(`https://${GetParentResourceName()}/closeJuiceMenu`, { method: "POST" });
  });
});

/* ========== NUICallback Triggers ========== */

// Called by the "🔪 Cut" button in the Cutting Menu
function cutFruit(fruitName, sliceName) {
  fetch(`https://${GetParentResourceName()}/cutFruit`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ fruit: fruitName, sliceItem: sliceName })
  });
}

// Called by the "🍹 Prepare" button in the Juice Menu
function prepareJuice(juiceName, requiredItem) {
  fetch(`https://${GetParentResourceName()}/prepareJuice`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ juiceType: juiceName, requiredItem: requiredItem })
  });
}
