use tauri::{
  menu::{Menu, MenuItem},
  tray::{MouseButton, MouseButtonState, TrayIconBuilder, TrayIconEvent},
  Manager,
};

const TRAY_ID: &str = "weather-tray";

fn show_main_window(app: &tauri::AppHandle) {
  if let Some(window) = app.get_webview_window("main") {
    let _ = window.unminimize();
    let _ = window.show();
    let _ = window.set_focus();
  }
}

fn setup_tray(app: &tauri::AppHandle) -> tauri::Result<()> {
  let show = MenuItem::with_id(app, "show", "Show Weather", true, None::<&str>)?;
  let quit = MenuItem::with_id(app, "quit", "Quit Weather", true, None::<&str>)?;
  let menu = Menu::with_items(app, &[&show, &quit])?;

  let mut tray = TrayIconBuilder::with_id(TRAY_ID)
    .tooltip("Weather")
    .title("Weather")
    .menu(&menu)
    .show_menu_on_left_click(true)
    .on_menu_event(|app, event| match event.id().as_ref() {
      "show" => show_main_window(app),
      "quit" => app.exit(0),
      _ => {}
    })
    .on_tray_icon_event(|tray, event| {
      if let TrayIconEvent::Click {
        button: MouseButton::Left,
        button_state: MouseButtonState::Up,
        ..
      } = event
      {
        show_main_window(tray.app_handle());
      }
    });

  if let Some(icon) = app.default_window_icon() {
    tray = tray.icon(icon.clone());
  }

  tray.build(app)?;
  Ok(())
}

#[tauri::command]
fn update_tray_temperature(
    app: tauri::AppHandle,
    label: String,
    tooltip: String,
) -> Result<(), String> {
  let label = label.trim();
  if label.is_empty() {
    return Ok(());
  }

  if let Some(tray) = app.tray_by_id(TRAY_ID) {
    tray.set_title(Some(label))
      .map_err(|err| err.to_string())?;
    tray.set_tooltip(Some(tooltip))
      .map_err(|err| err.to_string())?;
  }

  Ok(())
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
  tauri::Builder::default()
    .plugin(tauri_plugin_opener::init())
    .invoke_handler(tauri::generate_handler![update_tray_temperature])
    .setup(|app| {
      if let Err(err) = setup_tray(app.handle()) {
        eprintln!("failed to initialize tray icon: {err}");
      }
      if cfg!(debug_assertions) {
        app.handle().plugin(
          tauri_plugin_log::Builder::default()
            .level(log::LevelFilter::Info)
            .build(),
        )?;
      }
      Ok(())
    })
    .run(tauri::generate_context!())
    .expect("error while running tauri application");
}
