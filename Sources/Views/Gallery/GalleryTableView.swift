//
//  GalleryTableView.swift
//
//  Created by Yumenosuke Koukata on 2023/01/05.
//

import Kingfisher
import SFSafeSymbols
import SwiftUI
import WaterfallGrid
import QuickLook

struct GalleryTableView: View {
	@EnvironmentObject private var settingModel: AppSettingModel
	@EnvironmentObject private var galleryModel: GalleryModel

	@State private var popoverPresentedID: GalleryItem.ID?
	@State private var alertDeleteFile = false
	@State private var previewURL: URL?

	var body: some View {
		if galleryModel.isEmpty {
			Button {
				galleryModel.openDirectoryPicker()
			} label: {
				HStack {
					Image(systemSymbol: .folderFill)
					Text(R.string.localizable.buttonOpenFolder)
				}
				.padding(.all, 16)
			}
		} else {
			ScrollView(settingModel.galleryScrollAxis) {
				WaterfallGrid(galleryModel.items) { item in
					KFImage(item.url)
						.resizable()
						.aspectRatio(contentMode: .fit)
						.cornerRadius(8)
						.onTapGesture {
							switch galleryModel.mode {
								case .viewer:
									popoverPresentedID = item.id
								case let .multipleSelection(selected, hideSelected):
									if selected.contains(item) {
										galleryModel.mode = .multipleSelection(selected: selected.subtracting([item]), hideSelected: hideSelected)
									} else {
										galleryModel.mode = .multipleSelection(selected: selected.union([item]), hideSelected: hideSelected)
									}
							}
						}
						.popover(isPresented: $popoverPresentedID == item.id) {
							GalleryItemControlView(item: item, excludeTags: galleryModel.spellsFilter)
								.galleryItemControlAction { action in
									switch action {
										case .copyPrompt:
											galleryModel.copyPrompt(of: item)
										case .previewFile:
											previewURL = item.url
										case .openFile:
											galleryModel.openFile(item: item)
										case .deleteFile:
											galleryModel.deleteActual(item: item)
										case .select(let tag):
											galleryModel.spellsFilter.insert(tag)
									}
								}
								.frame(minWidth: 320)
								.padding(.all, 16)
						}
						.overlay(alignment: .topLeading) {
							if case let .multipleSelection(selected, _) = galleryModel.mode {
								let isItemSelected = selected.contains(item)
								HStack(spacing: 4) {
									let size: CGFloat = 18
									let color: Color = .white
									if isItemSelected {
										Image(systemSymbol: .checkmarkCircleFill)
											.font(.system(size: size))
											.foregroundColor(.red)
									} else {
										Image(systemSymbol: .checkmarkCircle)
											.font(.system(size: size))
											.foregroundColor(color)
									}
									Image(systemSymbol: .infoCircle)
										.font(.system(size: size))
										.foregroundColor(color)
										.onTapGesture {
											popoverPresentedID = item.id
										}
								}
								.padding(4)
							}
						}
				}
				.scrollOptions(direction: settingModel.galleryScrollAxis)
				.gridStyle(columns: settingModel.galleryColumns)
				.padding(8)
			}
			.padding(.top, 0.1) // Ensure toolbars and content do not overlap
			.quickLookPreview($previewURL)
		}
	}
}

struct GalleryTableView_Previews: PreviewProvider {
	static var previews: some View {
		GalleryTableView()
			.environmentObject(AppSettingModel())
			.environmentObject(GalleryModel())
	}
}

