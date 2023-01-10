//
//  GalleryItemControlView.swift
//  AAViewer
//
//  Created by Yumenosuke Koukata on 2023/01/10.
//

import SwiftUI

struct GalleryItemControlView: View {
	private let item: GalleryItem
	private let excludeTags: any Sequence<String>

	private var action: ((GalleryItemAction) -> Void)? = nil

	@Binding var alertDeleteFile: Bool

	init(item: GalleryItem, excludeTags: any Sequence<String>, alertDeleteFile: Binding<Bool>) {
		self.item = item
		self.excludeTags = excludeTags
		self._alertDeleteFile = alertDeleteFile
	}

	var body: some View {
		VStack(alignment: .center, spacing: 8) {
			Text(item.url.lastPathComponent)
			Divider()
			TagListView(tags: item.spells.map(\.phrase).reduce(into: []) { accum, phrase in
				guard !excludeTags.contains(phrase) else { return }
				accum.append(phrase)
			})
			.onOnTap { tag in
				action?(.select(tag: tag))
			}
			Divider()
			HStack {
				Button {
					action?(.copyPrompt)
				} label: {
					Image(systemName: "clipboard")
					Text("Copy Prompt")
				}
				Button {
					action?(.openFile)
				} label: {
					Image(systemName: "photo")
					Text("Open Image")
				}
				Button {
					alertDeleteFile = true
				} label: {
					Image(systemName: "trash")
					Text("Trash")
				}
				.alert(isPresented: $alertDeleteFile) {
					alert(deleteItem: item)
				}
			}
		}
	}

	@inlinable func onAction(perform action: @escaping (GalleryItemAction) -> Void) -> Self {
		var copied = self
		copied.action = action
		return copied
	}

	enum GalleryItemAction {
		case copyPrompt, openFile, deleteFile, select(tag: String)
	}
}

private extension GalleryItemControlView {
	func alert(deleteItem: GalleryItem) -> Alert {
		let path = item.url.absoluteString
		return Alert(title: Text("Do you want to delete the file immediately?"),
					 message: Text(path.removingPercentEncoding ?? path),
					 primaryButton: .destructive(Text("Yes"), action: { action?(.deleteFile) }),
					 secondaryButton: .cancel())
	}
}