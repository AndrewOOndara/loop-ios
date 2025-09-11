import SwiftUI

// MARK: - Notification Models
struct NotificationModel: Identifiable {
    let id = UUID()
    let type: NotificationType
    let title: String
    let message: String
    let timestamp: String
    let isRead: Bool
    let hasActions: Bool
    
    enum NotificationType {
        case upload
        case comment
        case invite
        case reminder
        case weeklyCollage
    }
}

struct NotificationView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Sample notification data based on the screenshot
    let notifications: [NotificationModel] = [
        // Today
        NotificationModel(
            type: .upload,
            title: "Maaz Zuberi",
            message: "uploaded a photo to jones 2025 at 11:25 AM.",
            timestamp: "Today",
            isRead: false,
            hasActions: false
        ),
        NotificationModel(
            type: .upload,
            title: "Spencer Kresie",
            message: "uploaded a song to rice volleyball at 8:01 AM.",
            timestamp: "Today",
            isRead: false,
            hasActions: false
        ),
        NotificationModel(
            type: .reminder,
            title: "Remember us?",
            message: "Don't forget to upload today! Your friends miss you <3!",
            timestamp: "Today",
            isRead: false,
            hasActions: false
        ),
        
        // Yesterday
        NotificationModel(
            type: .invite,
            title: "plano peoples",
            message: "sent you an invite.",
            timestamp: "Yesterday",
            isRead: false,
            hasActions: true
        ),
        NotificationModel(
            type: .weeklyCollage,
            title: "Your weekly collages from week 7/28 - 8/3 just cleared!",
            message: "Get ready for a new week!",
            timestamp: "Yesterday",
            isRead: false,
            hasActions: false
        ),
        
        // Last 7 Days
        NotificationModel(
            type: .comment,
            title: "Raag Venkat",
            message: "commented on your photo: no wayyy so cool!",
            timestamp: "Last 7 Days",
            isRead: false,
            hasActions: false
        ),
        NotificationModel(
            type: .weeklyCollage,
            title: "rice volleyball",
            message: "collage is ready! Go view it!",
            timestamp: "Last 7 Days",
            isRead: false,
            hasActions: false
        )
    ]
    
    var body: some View {
        ZStack {
            BrandColor.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(BrandColor.black)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Text("Notifications")
                        .font(BrandFont.title1)
                        .foregroundColor(BrandColor.black)
                    
                    Spacer()
                    
                    // Invisible spacer to balance the back button
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .opacity(0)
                }
                .padding(.horizontal, BrandSpacing.md)
                .padding(.top, BrandSpacing.sm)
                .padding(.bottom, BrandSpacing.md)
                
                // Notifications List
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        // Group notifications by time period
                        ForEach(["Today", "Yesterday", "Last 7 Days"], id: \.self) { period in
                            let periodNotifications = notifications.filter { $0.timestamp == period }
                            
                            if !periodNotifications.isEmpty {
                                // Section Header
                                HStack {
                                    Text(period)
                                        .font(BrandFont.title2)
                                        .foregroundColor(BrandColor.black)
                                    Spacer()
                                }
                                .padding(.horizontal, BrandSpacing.md)
                                .padding(.top, period == "Today" ? 0 : BrandSpacing.lg)
                                .padding(.bottom, BrandSpacing.sm)
                                
                                // Notifications for this period
                                ForEach(periodNotifications) { notification in
                                    NotificationRow(notification: notification)
                                }
                            }
                        }
                    }
                }
                
                // Bottom Navigation Bar (same as Home)
                NavigationBar(selectedTab: .constant(.home), onUploadTap: {
                    print("Upload tapped from notifications")
                })
            }
        }
        .navigationBarHidden(true)
    }
}

struct NotificationRow: View {
    let notification: NotificationModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: BrandSpacing.sm) {
                // Profile Icon or App Icon
                ZStack {
                    Circle()
                        .fill(BrandColor.cream)
                        .frame(width: 48, height: 48)
                    
                    if notification.type == .weeklyCollage {
                        // App logo for system notifications
                        RoundedRectangle(cornerRadius: 8)
                            .fill(BrandColor.orange)
                            .frame(width: 32, height: 32)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(BrandColor.white)
                                    .frame(width: 20, height: 20)
                            )
                    } else {
                        // User profile placeholder
                        Image(systemName: "person.fill")
                            .font(.system(size: 20))
                            .foregroundColor(BrandColor.orange)
                    }
                }
                
                // Notification Content
                VStack(alignment: .leading, spacing: BrandSpacing.xs) {
                    if notification.type == .reminder || notification.type == .weeklyCollage {
                        // System notifications
                        Text(notification.title)
                            .font(BrandFont.body)
                            .foregroundColor(BrandColor.black)
                        
                        if !notification.message.isEmpty {
                            Text(notification.message)
                                .font(BrandFont.body)
                                .foregroundColor(BrandColor.lightBrown)
                        }
                    } else {
                        // User notifications
                        HStack(spacing: 4) {
                            Text(notification.title)
                                .font(BrandFont.headline)
                                .foregroundColor(BrandColor.black)
                            
                            Text(notification.message)
                                .font(BrandFont.body)
                                .foregroundColor(BrandColor.black)
                        }
                    }
                }
                
                Spacer()
                
                // Action buttons for invites
                if notification.hasActions {
                    HStack(spacing: BrandSpacing.xs) {
                        Button {
                            // Accept invite
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(BrandColor.white)
                                .frame(width: 32, height: 32)
                                .background(BrandColor.orange)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            // Decline invite
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(BrandColor.white)
                                .frame(width: 32, height: 32)
                                .background(BrandColor.lightBrown)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, BrandSpacing.md)
            .padding(.vertical, BrandSpacing.sm)
            
            // Separator line (except for last item in each section)
            Rectangle()
                .fill(BrandColor.cream.opacity(0.5))
                .frame(height: 1)
                .padding(.leading, BrandSpacing.md + 48 + BrandSpacing.sm)
        }
    }
}

#Preview {
    NotificationView()
}
