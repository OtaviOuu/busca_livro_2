defmodule BuscaLivro.CustomCinderTheme do
  use Cinder.Theme

  extends :daisy_ui

  # --- Grid ---
  set :grid_item_class, ""
  set :grid_item_clickable_class, "cursor-pointer"
  set :grid_container_class, "grid gap-4"

  # --- Controls wrapper (envolve :controls slot + sort) ---
  set :controls_class, "card bg-base-100 border border-base-300 shadow-sm mb-4"

  # Zera o wrapper que o Cinder coloca em volta do <:controls> slot
  set :filter_container_class, ""

  # --- Filtros ---
  set :filter_input_wrapper_class, "form-control"
  set :filter_label_class, "label text-xs text-base-content/50 whitespace-nowrap pb-1"
  set :filter_text_input_class, "input input-sm input-bordered w-full"
  set :filter_date_input_class, "input input-sm input-bordered w-40"

  set :filter_number_input_class,
      "input input-sm input-bordered w-20 [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none [-moz-appearance:textfield]"

  set :filter_select_input_class, "select select-sm select-bordered w-48"
  set :filter_clear_all_class, "btn btn-ghost btn-xs text-base-content/40"
  set :filter_clear_button_class, "btn btn-ghost btn-xs text-base-content/40 ml-1"
  set :filter_count_class, "badge badge-primary badge-xs"

  # render_header — esconde o título "Filters", mostra só badge + clear all
  set :filter_header_class, "flex items-center gap-2"
  set :filter_title_class, "hidden"

  # Dropdowns
  set :filter_select_dropdown_class,
      "absolute z-50 w-full mt-1 bg-base-100 border border-base-300 rounded-box shadow-lg max-h-60 overflow-auto"

  set :filter_select_option_class,
      "px-4 py-2 hover:bg-base-200 border-b border-base-300 last:border-b-0 cursor-pointer text-sm"

  set :filter_multiselect_dropdown_class,
      "absolute z-50 w-full mt-1 bg-base-100 border border-base-300 rounded-box shadow-lg max-h-60 overflow-auto"

  set :filter_multiselect_option_class,
      "px-3 py-2 hover:bg-base-200 border-b border-base-300 last:border-b-0 cursor-pointer text-sm"

  # Search
  set :search_input_class, "input input-sm input-bordered w-full"
  set :search_icon_class, "hidden"

  # --- Sort ---
  set :sort_container_class, "border-t border-base-300"
  set :sort_controls_class, "py-2 px-4 flex flex-row items-center gap-2"
  set :sort_controls_label_class, "text-xs text-base-content/40 uppercase tracking-wide"
  set :sort_button_class, "btn btn-xs"
  set :sort_button_active_class, "btn-primary"
  set :sort_button_inactive_class, "btn-ghost text-base-content/60"

  # --- Pagination ---
  set :pagination_wrapper_class, "px-4 py-3 border-t border-base-300"
  set :pagination_button_class, "btn btn-sm btn-ghost border border-base-300"
  set :pagination_current_class, "btn btn-sm btn-primary"

  set :page_size_dropdown_class,
      "btn btn-sm btn-ghost border border-base-300 flex items-center cursor-pointer"

  set :page_size_dropdown_container_class,
      "bg-base-100 border border-base-300 rounded-box shadow-lg"

  set :page_size_selected_class, "bg-primary/10 text-primary font-medium"
end
