// (C) Copyright 2015 Moodle Pty Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import { Injectable } from '@angular/core';
import { CoreCourseHelper } from '@features/course/services/course-helper';
import { CorePushNotificationsClickHandler } from '@features/pushnotifications/services/push-delegate';
import { CorePushNotificationsNotificationBasicData } from '@features/pushnotifications/services/pushnotifications';
import { CoreUrl } from '@singletons/url';
import { CoreUtils } from '@singletons/utils';
import { makeSingleton } from '@singletons';
import { AddonModAssign } from '../assign';
import { ADDON_MOD_ASSIGN_FEATURE_NAME, ADDON_MOD_ASSIGN_PAGE_NAME } from '../../constants';
import { CorePromiseUtils } from '@singletons/promise-utils';

/**
 * Handler for assign push notifications clicks.
 */
@Injectable({ providedIn: 'root' })
export class AddonModAssignPushClickHandlerService implements CorePushNotificationsClickHandler {

    name = 'AddonModAssignPushClickHandler';
    priority = 200;
    featureName = ADDON_MOD_ASSIGN_FEATURE_NAME;

    /**
     * @inheritdoc
     */
    async handles(notification: NotificationData): Promise<boolean> {
        return CoreUtils.isTrueOrOne(notification.notif) &&
            notification.moodlecomponent === ADDON_MOD_ASSIGN_PAGE_NAME &&
                notification.name === 'assign_notification';
    }

    /**
     * @inheritdoc
     */
    async handleClick(notification: NotificationData): Promise<void> {
        const contextUrlParams = CoreUrl.extractUrlParams(notification.contexturl);
        const courseId = Number(notification.courseid);
        const moduleId = Number(contextUrlParams.id);

        await CorePromiseUtils.ignoreErrors(AddonModAssign.invalidateContent(moduleId, courseId, notification.site));
        await CoreCourseHelper.navigateToModule(moduleId, {
            courseId,
            siteId: notification.site,
        });
    }

}
export const AddonModAssignPushClickHandler = makeSingleton(AddonModAssignPushClickHandlerService);

type NotificationData = CorePushNotificationsNotificationBasicData & {
    courseid: number;
    contexturl: string;
};
