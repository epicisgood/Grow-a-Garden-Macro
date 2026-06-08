let cachedData = null;

async function fetchAllItems() {
  if (!cachedData) {
    const response = await fetch('https://raw.githubusercontent.com/epicisgood/GAG-Updater/refs/heads/main/items.json');
    cachedData = await response.json();
  }
  return cachedData;
}

async function getCategoryData(category) {
  const data = await fetchAllItems();
  return {
    rawItems: data[category],
    names: data[category].map(item => item.name)
  };
}






async function onSaveClick() {
  const cfg = {
    url: document.getElementById('url').value,
    discordID: document.getElementById('discordID').value,
    VipLink: document.getElementById('VipLink').value,
    TravelingMerchant: +document.getElementById('TravelingMerchant').checked,
    Cosmetics: +document.getElementById('Cosmetics').checked,
    CookingEvent: +document.getElementById('CookingEvent').checked,
    SearchList: document.getElementById('SearchList').value,
    CookingTime: document.getElementById('CookingTime').value,
    ThemeToggle: +document.getElementById('ThemeToggle').checked,

    dynamicItems: {} 
  };

  for (const category of CATEGORIES) {
    const { names } = await getCategoryData(category);
    names.push(category);

    cfg.dynamicItems[category] = {};

    names.forEach(name => {
      const element = document.getElementById(sanitizeId(name));
      if (element) {
        cfg.dynamicItems[category][name] = element.checked;
      }
    });
  }

  ahk.Save.Func(JSON.stringify(cfg));
  console.log("Config Saved:", cfg);
}
  
function applySettings(payload) {
  const settings = payload.data;
  console.log("Applying incoming configurations:", settings);

  const fieldMap = {
    'url': settings.url,
    'discordID': settings.discordID,
    'VipLink': settings.VipLink,
    'SearchList': settings.SearchList,
    'CookingTime': settings.CookingTime,
    'ThemeToggle': !!+settings.ThemeToggle,
    'Cosmetics': !!+settings.Cosmetics,
    'TravelingMerchant': !!+settings.TravelingMerchant,
    'CookingEvent': !!+settings.CookingEvent
  };

  Object.entries(fieldMap).forEach(([id, value]) => {
    const el = document.getElementById(id);
    if (el) {
      if (el.type === 'checkbox' || el.type === 'radio') el.checked = value;
      else el.value = value;
    }
  });

  if (settings.dynamicItems) {
    Object.entries(settings.dynamicItems).forEach(([category, items]) => {
      for (const itemName in items) {
        const el = document.getElementById(sanitizeId(itemName));
        if (el) el.checked = !!+items[itemName];
      }
    });
  }

  handleThemeChange();

}




const CATEGORIES = [
  "Seeds", "Gears", "Eggs", "GearCrafting", "SeedCrafting", "EasterSeed", "CreepyCritters"
];


const sanitizeId = (str) => str.replace(/\s+/g, '');

const getInputType = (category) => ["GearCrafting", "SeedCrafting"].includes(category) ? "radio" : "checkbox";


async function buildDynamicItemGrids() {
  for (const category of CATEGORIES) {
    const { rawItems } = await getCategoryData(category);
    const rewardGrid = document.querySelector(`#${category}Grid`);
    if (!rewardGrid) continue;

    const inputType = getInputType(category);
    const inputName = inputType === "radio" ? `name="${category}"` : "";

    rawItems.forEach(item => {
      const sanitizedName = sanitizeId(item.name);
      const imgPath = item.image || `../../images/${category}/${item.name}.webp`;

      const boxCard = document.createElement("div");
      boxCard.className = "reward-box";
      boxCard.innerHTML = `
        <div class="reward-header">
          <img src="${imgPath}" style="width: 28px; height: 28px; vertical-align: middle;" onerror="this.src='../../images/Other/Placeholder.webp'">
          <span>${item.name}</span>
        </div>
        <div class="reward-options">
          <label><input type="${inputType}" id="${sanitizedName}" ${inputName}>Claim</label>
        </div>
      `;
      rewardGrid.appendChild(boxCard);
    });
  }
}



document.addEventListener("DOMContentLoaded", async () => {

  await buildDynamicItemGrids();
  ahk.ReadSettings.Func();
  window.chrome.webview.addEventListener('message', applySettings);

  initTooltipSystem();
  initDropdownControllers();

  document.querySelectorAll('.tabs button').forEach(button => {
    button.addEventListener('click', function() {
      document.querySelectorAll('.tabs button').forEach(btn => btn.classList.remove('tab-button-active'));
      this.classList.add('tab-button-active');
    });
  });

  document.querySelectorAll(".SelectAll").forEach(selectAllCheckbox => {
    selectAllCheckbox.addEventListener("change", () => {
      const rewardGrid = selectAllCheckbox.closest(".rewards-grid");
      if (!rewardGrid) return;

      rewardGrid.querySelectorAll("input[type='checkbox']").forEach(cb => {
        const isControl = cb.classList.contains("SelectAll") || CATEGORIES.includes(cb.id);
        if (!isControl) {
          cb.checked = selectAllCheckbox.checked;
        }
      });

      onSaveClick();
    });
  });

  const container = document.querySelector('.container');
  if (container) {
    container.addEventListener('change', (event) => {
      const target = event.target;
      if (target.matches('input[type="checkbox"], input[type="text"], input[type="radio"]')) {
        console.log(`Auto-saving layout state change on: #${target.id || 'Dynamic Entry'}`);
        onSaveClick();
      }
    });
  }


});























// Some Fancy GUI stuff




const themeToggle = document.getElementById('ThemeToggle');
if (themeToggle) {

  handleThemeChange(); 
  
  themeToggle.addEventListener('change', handleThemeChange);
}

function handleThemeChange() {
  const themeToggle = document.getElementById('ThemeToggle');
  if (themeToggle && themeToggle.checked) {
    document.body.classList.add('light-theme');
  } else {
    document.body.classList.remove('light-theme');
  }
};






function switchTab(tabId) {
  document.querySelectorAll('.tab').forEach(tab => tab.classList.remove('active'));
  
  const activeTab = document.getElementById(tabId);
  if (activeTab) activeTab.classList.add('active');
}

function switchSubTab(subTabId) {
  document.querySelectorAll('.sub-tab').forEach(tab => tab.classList.remove('active'));
  document.querySelectorAll('.sidebar-btn').forEach(btn => btn.classList.remove('active'));
  
  const targetSubTab = document.getElementById(subTabId);
  if (targetSubTab) targetSubTab.classList.add('active');
  
  if (window.event && window.event.currentTarget) {
    window.event.currentTarget.classList.add('active');
  }
}



function initTooltipSystem() {
  document.querySelectorAll('.info-tooltip-holder').forEach(holder => {
    const box = holder.querySelector('.tooltip-box');
    let hideTimeout;

    holder.addEventListener('mouseenter', () => {
      clearTimeout(hideTimeout);
      holder.classList.remove('left-snap', 'right-snap', 'top-snap', 'bottom-snap');

      const rect = holder.getBoundingClientRect();
      const container = holder.closest('.sidebar-content-view') || holder.closest('.tab');
      if (!container) return;
      
      const containerRect = container.getBoundingClientRect();

      // Horizontal checking
      if ((rect.left - 110) < containerRect.left) holder.classList.add('left-snap');
      else if ((rect.right + 110) > containerRect.right) holder.classList.add('right-snap');

      // Vertical checking
      if ((rect.top - 55) < containerRect.top) holder.classList.add('top-snap');
      else if ((rect.bottom + 55) > containerRect.bottom) holder.classList.add('bottom-snap');

      if (box) box.classList.add('visible');
    });

    holder.addEventListener('mouseleave', () => {
      hideTimeout = setTimeout(() => {
        if (box) box.classList.remove('visible');
        holder.classList.remove('left-snap', 'right-snap', 'top-snap', 'bottom-snap');
      }, 200);
    });
  });
}

function initDropdownControllers() {
  document.querySelectorAll('.custom-dropdown').forEach(dropdown => {
    const selected = dropdown.querySelector('.custom-dropdown-selected');
    const options = dropdown.querySelector('.custom-dropdown-options');
    const hiddenInput = document.getElementById('hiddenSelector');

    selected.addEventListener('click', () => {
      options.style.display = options.style.display === 'block' ? 'none' : 'block';
    });

    options.querySelectorAll('[data-value]').forEach(option => {
      option.addEventListener('click', () => {
        const value = option.getAttribute('data-value');
        selected.textContent = option.textContent.trim();
        if (hiddenInput) hiddenInput.value = value;
        options.style.display = 'none';
      });
    });

    document.addEventListener('click', e => {
      if (!dropdown.contains(e.target)) options.style.display = 'none';
    });
  });
}






