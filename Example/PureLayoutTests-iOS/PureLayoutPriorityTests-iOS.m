//
//  PureLayoutPriorityTests-iOS.m
//  PureLayout Tests
//
//  Copyright (c) 2014 Tyler Fox
//  https://github.com/smileyborg/PureLayout
//

#import "PureLayoutTestBase.h"

#define DEFINE_WEAK_SELF    __weak __typeof(self) weakSelf = self;

@interface PureLayoutPriorityTestsiOS : PureLayoutTestBase

@end

@implementation PureLayoutPriorityTestsiOS

- (void)setUp
{
    [super setUp];

}

- (void)tearDown
{

    [super tearDown];
}

/**
 Returns an array of the default priorities to test.
 */
- (NSArray *)defaultPriorities
{
    return @[@(ALLayoutPriorityFittingSizeLevel), @(ALLayoutPriorityDefaultHigh), @(ALLayoutPriorityRequired), @(ALLayoutPriorityDefaultLow)];
}

/**
 A helper method that takes a block containing a call to the UIView+AutoLayout API which adds one constraint,
 and calls -[assertConstraint:isAddedWithPriority:] for each of the default priorities.
 */
- (void)assertConstraintIsAddedWithDefaultPriorities:(NSLayoutConstraint *(^)())block
{
    for (NSNumber *layoutPriority in [self defaultPriorities]) {
        [self assertConstraint:block isAddedWithPriority:[layoutPriority floatValue]];
    }
}

/**
 A helper method that takes a block containing one or more calls to the UIView+AutoLayout API which add multiple
 constraints, and calls -[assertConstraints:areAddedWithPriority:] for each of the default priorities.
 */
- (void)assertConstraintsAreAddedWithDefaultPriorities:(NSArray *(^)())block
{
    for (NSNumber *layoutPriority in [self defaultPriorities]) {
        [self assertConstraints:block areAddedWithPriority:[layoutPriority floatValue]];
    }
}

/**
 A helper method that takes a block containing a call to the UIView+AutoLayout API which adds one constraint,
 and verifies that when the +[UIView autoSetPriority:forConstraints:] method is used, this one constraint is
 added with the correct priority specified.
 */
- (void)assertConstraint:(NSLayoutConstraint *(^)())block isAddedWithPriority:(ALLayoutPriority)priority
{
    [self assertConstraints:^NSArray *{ return @[block()]; } areAddedWithPriority:priority];
}

/**
 A helper method that takes a block containing one or more calls to the UIView+AutoLayout API which add multiple
 constraints, and verifies that when the +[UIView autoSetPriority:forConstraints:] method is used, these 
 constraints are added with the correct priority specified.
 */
- (void)assertConstraints:(NSArray *(^)())block areAddedWithPriority:(ALLayoutPriority)priority
{
    __block NSArray *constraints;
    [ALView autoSetPriority:priority forConstraints:^{
        constraints = block();
    }];
    XCTAssert([constraints count] > 0, @"The array of constraints should not be empty.");
    for (NSLayoutConstraint *constraint in constraints) {
        XCTAssert(constraint.priority == priority, @"The constraint priority should be equal to the one specified for the constraints block.");
    }
}

/**
 Test setting the priority of the content compression resistance and content hugging implicit constraints.
 */
- (void)testPriorityForContentCompressionResistanceAndContentHugging
{
    ALLabel *labelA = [ALLabel newAutoLayoutView]; // use ALLabel since it will have all 4 implicit constraints generated
    labelA.text = @"Some text.";
    
    [ALView autoSetPriority:ALLayoutPriorityRequired forConstraints:^{
        [labelA autoSetContentCompressionResistancePriorityForAxis:ALAxisHorizontal];
    }];
    XCTAssert([labelA contentCompressionResistancePriorityForAxis:UILayoutConstraintAxisHorizontal] == ALLayoutPriorityRequired, @"The constraint priority should be equal to the one specified for the constraints block.");
    
    [ALView autoSetPriority:ALLayoutPriorityFittingSizeLevel + 1 forConstraints:^{
        [labelA autoSetContentCompressionResistancePriorityForAxis:ALAxisVertical];
    }];
    XCTAssert([labelA contentCompressionResistancePriorityForAxis:UILayoutConstraintAxisVertical] == ALLayoutPriorityFittingSizeLevel + 1, @"The constraint priority should be equal to the one specified for the constraints block.");
    
    [ALView autoSetPriority:ALLayoutPriorityRequired forConstraints:^{
        [labelA autoSetContentHuggingPriorityForAxis:ALAxisHorizontal];
    }];
    XCTAssert([labelA contentHuggingPriorityForAxis:ALLayoutConstraintAxisHorizontal] == ALLayoutPriorityRequired, @"The constraint priority should be equal to the one specified for the constraints block.");
    
    [ALView autoSetPriority:ALLayoutPriorityDefaultHigh - 1 forConstraints:^{
        [labelA autoSetContentHuggingPriorityForAxis:ALAxisVertical];
    }];
    XCTAssert([labelA contentHuggingPriorityForAxis:UILayoutConstraintAxisVertical] == ALLayoutPriorityDefaultHigh - 1, @"The constraint priority should be equal to the one specified for the constraints block.");
}

/**
 Test setting the priority of constraints that pin views to the view controller layout guides.
 */
- (void)testPriorityForPinningToLayoutGuides
{
    DEFINE_WEAK_SELF
    
    UIViewController *viewController = [[UIViewController alloc] initWithNibName:nil bundle:nil];
    [viewController view]; // touch view to load it
    
    [self assertConstraintIsAddedWithDefaultPriorities:^NSLayoutConstraint *{
        return [weakSelf.viewA autoPinToTopLayoutGuideOfViewController:viewController withInset:50.0];
    }];
    
    [self assertConstraintIsAddedWithDefaultPriorities:^NSLayoutConstraint *{
        return [weakSelf.viewA autoPinToTopLayoutGuideOfViewController:viewController withInset:0.0];
    }];
    
    [self assertConstraintIsAddedWithDefaultPriorities:^NSLayoutConstraint *{
        return [weakSelf.viewA autoPinToBottomLayoutGuideOfViewController:viewController withInset:-5.0];
    }];
}

@end
