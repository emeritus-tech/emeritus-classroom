//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import SwiftUI

struct CourseCard: View {
    @ObservedObject var card: DashboardCard
    let hideColorOverlay: Bool
    let showGrade: Bool
    let width: CGFloat
    let contextColor: UIColor
    /** Wide layout puts the course image to the left of the cell while the course name and code will be next to it on the right. */
    let isWideLayout: Bool

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    var a11yGrade: String {
        guard let course = card.course, showGrade else { return "" }
        return course.displayGrade
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Button {
                env.router.route(to: "/courses/\(card.id)?contextColor=\(contextColor.hexString.dropFirst())", from: controller)
            } label: {
                if isWideLayout {
                    regularHorizontalLayout
                } else {
                    compactHorizontalLayout
                }
            }
            .buttonStyle(ScaleButtonStyle(scale: 1))
            .accessibility(label: Text(verbatim: "\(card.shortName) \(card.courseCode) \(a11yGrade)".trimmingCharacters(in: .whitespacesAndNewlines)))
            .identifier("DashboardCourseCell.\(card.id)")

            gradePill
                .accessibility(hidden: true) // handled in the button label
                .offset(x: 8, y: 8)
                .zIndex(1)
        }
    }

    private var regularHorizontalLayout: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // 1.77 to have 16:9 ratio
                courseImage(width: 1.77 * geometry.size.height, height: geometry.size.height)
                textArea
            }
            .contentShape(Rectangle())
            .background(RoundedRectangle(cornerRadius: 4).stroke(Color.gray, lineWidth: 1 / UIScreen.main.scale))
            .background(Color.backgroundLightest)
            .cornerRadius(4)
        }
    }

    private var compactHorizontalLayout: some View {
        VStack(alignment: .leading, spacing: 0) {
            courseImage(width: width)
            textArea
        }
        .contentShape(Rectangle())
        .background(RoundedRectangle(cornerRadius: 4).stroke(Color.gray, lineWidth: 1 / UIScreen.main.scale))
        .background(Color.backgroundLightest)
        .cornerRadius(4)
    }

    private func courseImage(width: CGFloat, height: CGFloat = 80) -> some View {
        ZStack(alignment: .topLeading) {
            Color(card.color).frame(width: width, height: height)
            card.imageURL.map { RemoteImage($0, width: width, height: height) }?
                .opacity(hideColorOverlay ? 1 : 0.4)
                .clipped()
                // Fix big course image consuming tap events.
                .contentShape(Path(CGRect(x: 0, y: 0, width: width, height: height)))
            customizeButton
                .offset(x: width - 44, y: 0)
        }
    }

    private var textArea: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack { Spacer() }
            Text(card.shortName)
                .font(.semibold18).foregroundColor(Color(card.color))
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(2)
            Text(card.courseCode)
                .font(.semibold12).foregroundColor(.textDark)
                .lineLimit(2)
            Spacer()
        }
        .padding(.horizontal, 10).padding(.top, 8)
    }

    private var customizeButton: some View {
        Button {
            guard let course = card.course else { return }
            env.router.show(
                CoreHostingController(CustomizeCourseView(course: course, hideColorOverlay: hideColorOverlay)),
                from: controller,
                options: .modal(.formSheet, isDismissable: false, embedInNav: true),
                analyticsRoute: "/dashboard/customize_course"
            )
        } label: {
            Image.moreSolid.foregroundColor(Color(contextColor))
                .background(Circle().fill(Color.backgroundLightest).frame(width: 28, height: 28)
                )
                .frame(width: 44, height: 44)
        }
        .accessibility(label: Text("Open \(card.shortName) user preferences", bundle: .core))
        .identifier("DashboardCourseCell.\(card.id).optionsButton")
    }

    @ViewBuilder
    private var gradePill: some View {
        if showGrade, let course = card.course {
            HStack {
                if course.hideTotalGrade {
                    Image.lockSolid.size(14)
                } else {
                    Text(course.displayGrade).font(.semibold14)
                }
            }
            .foregroundColor(Color(contextColor))
            .padding(.horizontal, 6).frame(height: 20)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.backgroundLightest))
            .frame(maxWidth: 120, alignment: .leading)
        }
    }
}

#if DEBUG

struct CourseCard_Previews: PreviewProvider {
    private static let env = PreviewEnvironment()
    private static let context = env.globalDatabase.viewContext
    private static var cardEntity: DashboardCard {
        let apiEnrollment = APIEnrollment.make(computed_current_score: 105, computed_current_grade: "A+")
        let apiCourse = APICourse.make(enrollments: [apiEnrollment])
        Course.save(apiCourse, in: context)

        let apiContextColor = APICustomColors(custom_colors: ["course_1": "#008EE2"])
        ContextColor.save(apiContextColor, in: context)

        let apiEntity = APIDashboardCard.make(courseCode: "Course_PRV_001_2023/03/03-Term1-Section3",
                                              shortName: "Mrs. Robinson's Reading Lectures For Elementary Class")
        return DashboardCard.save(apiEntity, position: 0, in: context)
    }

    static var previews: some View {
        VStack(alignment: .leading) {
            Text(verbatim: "Grid Layout")
            CourseCard(card: cardEntity,
                       hideColorOverlay: false,
                       showGrade: true,
                       width: 200,
                       contextColor: .electric,
                       isWideLayout: false)
            .frame(width: 200, height: 160)
            .environment(\.horizontalSizeClass, .compact)

            Text(verbatim: "List Layout - Compact Horizontal Size Class").padding(.top)
            CourseCard(card: cardEntity,
                       hideColorOverlay: false,
                       showGrade: true,
                       width: 400,
                       contextColor: .electric,
                       isWideLayout: false)
            .frame(width: 400, height: 160)
            .environment(\.horizontalSizeClass, .compact)

            Text(verbatim: "List Layout - Regular Horizontal Size Class").padding(.top)
            CourseCard(card: cardEntity,
                       hideColorOverlay: false,
                       showGrade: true,
                       width: 900,
                       contextColor: .electric,
                       isWideLayout: true)
            .frame(width: 900, height: 100)
            .environment(\.horizontalSizeClass, .regular)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

#endif
