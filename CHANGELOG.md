# Changelog

## 1.0.0-dev.1

A pre-release of 1.0.0, for testing before it's final. The API may still change between dev versions.

A rewrite. See "Migrating from 0.x" in the README.

- Pages keep their state while they're in the stack. Pushing over a page and popping back no longer rebuilds it, and `initState` runs once per page. ([#10](https://github.com/danielkiing3/family_bottom_sheet/issues/10))
- Pages are no longer mounted twice, so a `GlobalKey` inside a page no longer throws.
- The first page's builder can read inherited widgets such as `Theme.of`, `Localizations.of` and `MediaQuery.of`; it's no longer built in `initState`. ([#17](https://github.com/danielkiing3/family_bottom_sheet/issues/17), with thanks to [empiresdev](https://github.com/empiresdev) for [#18](https://github.com/danielkiing3/family_bottom_sheet/pull/18))
- The sheet resizes from the pages' live sizes, mid-transition included.
- Bespoke look: `surfaceBuilder` and `pageTransitionBuilder` replace the fixed Material styling. Ready-made transitions are in `FamilyPageTransitions`.
- New `FamilyMotion`: springs (the default) or curves for the sheet and pages. A released drag keeps its speed.
- Rubber band: dragging past fully open stretches the sheet and springs it back, and a sheet that can't close (`enableDrag: false` or `canUserDismiss` false) gives a little when dragged down.
- Sheets can be docked to the bottom edge or floating in the middle (`FamilySheetPlacement.docked()` / `.floating()`), with the same drag, scroll handoff and rubber band. Docked sheets are capped at 640 wide and floating ones at 540, centred.
- Floating sheets keep their top edge still as they resize between pages (`FamilyAnchor.top`, `center` or `bottom`).
- One route, `FamilyModalRoute`, for every presentation. New `canUserDismiss` on it, to block closing by barrier, drag and back (on any page, the first included) while something can't be interrupted.
- New `FamilySheetTheme` for app-wide defaults, and `FamilySheetTheme.of` with the package defaults filled in.
- New `presentation` option on `show`: `FamilyPresentationStyle.sheet`, `.adaptive` (docked on phones, floating on tablets, switching live as the window resizes or the device rotates, with pages keeping their state), or `.resolve` for your own rule. `copyWith` changes one setting on any of them, e.g. the theme's presentation for one sheet. `FamilyPresentation.maybeOf` (`docked` or `floating`) lets surfaces and pages adapt.
- Dragging a list down from its top drags the sheet closed (`FamilyPresentationStyle.sheet(dragFromScroll: ...)`), using `scroll_drag_detector`.
- Pages can pass a result back: `pushPage<R>` returns a future that completes with the value passed to `popPage`, and on the first page `popPage(result)` closes the sheet and `show` returns it. ([#11](https://github.com/danielkiing3/family_bottom_sheet/issues/11))
- New `replacePage` and `popToFirstPage`.
- New `FamilyPageStack` to host the page stack in your own container.
- The system back gesture pops a page before closing the sheet. Tapping the barrier still closes the whole sheet.
- The package no longer sets `uses-material-design`, so apps that turn it off no longer get a warning. ([#14](https://github.com/danielkiing3/family_bottom_sheet/issues/14), with thanks to [noordawod](https://github.com/noordawod) for [#15](https://github.com/danielkiing3/family_bottom_sheet/pull/15))
- The core no longer depends on Material. The Material preset is `FamilyMaterialSheet` in `package:family_bottom_sheet/material.dart`: the standard Material bottom sheet when docked (flush, top corners rounded), with `padding`, `borderRadius` and `floatingBorderRadius` to change it.
- Breaking: the styling options on `show` were removed in favour of `surfaceBuilder`. Sheet options moved into `FamilyPresentationStyle.sheet`. `showMaterialDefault` was removed. `canPopPage()` and `getTotalPageCount()` are now the getters `canPopPage` and `pageCount`.
- Requires Flutter 3.32 or later.

## 0.1.0
- Expose new api for canPopPage and getTotalPageCount
- Expose scrollControlDisabledMaxHeightRatio in show and showMaterialDefault method
- Added new example content demonstrating support for scrollable content in the modal and improve support scrollable content. [#7](https://github.com/danielkiing3/family_bottom_sheet/pull/7) by [MrLepage](https://github.com/MrLepage)
- Fix No named parameter with the name 'requestFocus' for lower flutter version

## 0.0.2

- Added a demo GIF to the `README.md` for visual demonstration of the bottom sheet
- Refactor example/main.dart to show actual example usage of the package.

## 0.0.1

- Initial version.